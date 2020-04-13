-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

-- dependencies
local event = require('__RaiLuaLib__.lualib.event')
local migration = require('__RaiLuaLib__.lualib.migration')
local mod_gui = require('mod-gui')
local translation = require('__RaiLuaLib__.lualib.translation')
local util = require('__core__.lualib.util')

-- locals
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match

-- libraries
local gui = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- builds data about item prototypes and iteration tables for translating them
local function build_prototype_data()
  local item_data = {} -- prototype name -> data: actually used to find sprites and such
  local translation_data = {} -- serialised localised string -> prototype name
  for name,prototype in pairs(game.item_prototypes) do
    item_data[name] = {localised_name=prototype.localised_name, hidden=prototype.has_flag('hidden')}
    translation_data[#translation_data+1] = {localised=prototype.localised_name, internal=prototype.name}
  end
  -- store build data in translation table
  global.__lualib.translation.translation_data = translation_data
  -- store item data to be retrieved after searching
  global.item_data = item_data
end

-- closes all of a player's open GUIs
local function close_player_guis(player, player_table)
  player_table.flags.can_open_gui = false
  if player_table.gui then
    gui.close(player, player_table)
  end
end

-- runs translations for all currently connected players
local function translate_for_all_players()
  local translation_data = global.__lualib.translation.translation_data
  for _,player in ipairs(game.connected_players) do
    translation.start(player, 'items', translation_data)
  end
end

-- setup player global table
local function setup_player(player)
  global.players[player.index] = {
    flags = {
      can_open_gui = false,
      translate_on_join = true
    },
    logistics_requests = {}
  }
end

-- updates temporary request counts
local function update_request_counts(e)
  local player = game.get_player(e.player_index)
  if not player.character then return end
  local character = player.character
  local player_table = global.players[e.player_index]
  local inv_contents = player.get_main_inventory().get_contents()
  if player.cursor_stack and player.cursor_stack.valid_for_read then
    local stack = player.cursor_stack
    inv_contents[stack.name] = stack.count + (inv_contents[stack.name] or 0)
  end
  -- build table of the player's current requests
  local requests = {}
  local get_slot = character.get_request_slot
  for i=1,character.request_slot_count do
    local slot = get_slot(i)
    if slot then
      requests[slot.name] = i
    end
  end
  -- for each request we're keeping track of
  local tracked_requests = player_table.logistics_requests
  for name,count in pairs(tracked_requests) do
    local request = requests[name]
    if request then
      if (inv_contents[name] or 0) >= count then
        -- clear request
        character.clear_request_slot(request)
        tracked_requests[name] = nil
      end
    else
      -- stop tracking this request, as it has been canceled
      tracked_requests[name] = nil
    end
  end
  if table_size(requests) == 0 then
    -- disable this event
    event.disable('update_request_counts', player.index)
  end
end

local function search_for_items(player, player_table, query, results_table)
  local player_settings = player.mod_settings
  local show_hidden = player_settings['qis-search-hidden'].value
  -- fuzzy search
  if player_settings['qis-fuzzy-search'].value then
    query = query:gsub('.', '%1.*')
  end
  query = string_lower(query)

  -- data
  local children = results_table.children
  local translations = player_table.dictionary.translations
  local item_data = global.item_data
  local add = results_table.add
  local index = 0
  local results = {}
  local button_indexes = {}

  -- add or update the next result button
  local function set_result(type, name, number)
    index = index + 1
    results[name] = number
    local button = children[index]
    if button then
      button.style = 'qis_slot_button_'..type
      button.sprite = 'item/'..name
      button.tooltip = translations[name]
      button.number = number
    else
      button = add{type='sprite-button', style='qis_slot_button_'..type, sprite='item/'..name, number=number,
        tooltip=translations[name]}
    end
    button_indexes[index] = button.index
  end

  -- match the query to the given name
  local function match_query(name, translation, ignore_unique)
    return (ignore_unique or not results[name]) and (show_hidden or not item_data[name].hidden)
      and string_match(string_lower(translation or translations[name]), query)
  end

  -- map editor
  if player.controller_type == defines.controllers.editor then
    local contents = player.get_main_inventory().get_contents()
    for internal,translated in pairs(translations) do
      -- we don't care about hidden or other results, so use an optimised condition
      if string_match(string_lower(translated), query) then
        set_result('inventory', internal, contents[internal])
      end
    end
  else
    -- player inventory
    if player_settings['qis-search-inventory'].value then
      local contents = player.get_main_inventory().get_contents()
      for name,count in pairs(contents) do
        if match_query(name) then
          set_result('inventory', name, count)
        end
      end
    end
    -- logistic network(s)
    if player.character and player_settings['qis-search-logistics'].value then
      local ignore_unique = not player_settings['qis-logistics-unique-only'].value
      local character = player.character
      local network_contents = {}
      for _,point in ipairs(character.get_logistic_point()) do
        local network = point.logistic_network
        if network.valid then
          local contents = point.logistic_network.get_contents()
          for name,count in pairs(contents) do
            if match_query(name, nil, not network_contents[name] and ignore_unique) then
              network_contents[name] = count
              set_result('logistics', name, count)
            end
          end
        end
      end
    end
    -- unavailable
    if player_settings['qis-search-unavailable'].value then
      for internal,translated in pairs(translations) do
        if match_query(internal, translated) then
          set_result('unavailable', internal)
        end
      end
    end
  end

  -- remove extra buttons, if any
  for i=index+1, #children do
    children[i].destroy()
  end

  -- set event GUI filters
  event.update_gui_filters('result_button_clicked', player.index, button_indexes, 'overwrite')
end

-- take action on the selected item
local function take_item_action(player, player_table, name, count, type, shift, control, slot_to_insert)
  local prototype = game.item_prototypes[name]
  local stack_size = slot_to_insert and count or prototype.stack_size
  local function set_ghost_cursor()
    player.clean_cursor()
    if prototype.place_result then
      player.cursor_ghost = name
    end
  end
  if type == 'inventory' then
    if count == 0 and player.controller_type == defines.controllers.editor then -- editor
      player.clean_cursor()
      player.cursor_stack.set_stack{name=name, count=stack_size}
    else
      player.clean_cursor()
      player.cursor_stack.set_stack{name=name, count=player.get_main_inventory().remove{name=name, count=stack_size}}
    end
    if player.controller_type == defines.controllers.editor and shift then
      local index = #player.infinity_inventory_filters + 1
      player.set_infinity_inventory_filter(index, {name=name, count=stack_size, mode='exactly', index=index})
    end
    gui.close(player, player_table)
  elseif type == 'logistics' and player.character and player.character.valid then
    local character = player.character
    if shift then
      set_ghost_cursor()
      gui.close(player, player_table)
    else -- request from logistic network
      if not slot_to_insert then
        local get_slot = character.get_request_slot
        -- check each request slot for our item
        for i=1,character.request_slot_count do
          local slot = get_slot(i)
          if slot == nil then
            slot_to_insert = i
            break
          elseif slot.name == name then
            player.print{'qis-message.already-requested-item', global.item_data[name].localised_name}
            return
          end
        end
      end
      if not slot_to_insert then
        player.print{'qis-message.out-of-request-slots'}
        return
      end
      -- open custom request GUI
      if control then
        local gui_data = player_table.gui
        gui_data.results_scroll.visible = false
        gui_data.input_flow.visible = true
        gui_data.state = 'input_request_amount'
        gui_data.selected_item_name = name
        gui_data.slot_to_insert = slot_to_insert
        gui_data.input_textfield.text = stack_size
        gui_data.input_textfield.select_all()
        gui_data.input_textfield.focus()
        player.opened = gui_data.input_textfield
      -- request a stack
      else
        character.set_request_slot({name=name, count=stack_size}, slot_to_insert)
        player.print{'qis-message.request-from-logistic-network', stack_size, global.item_data[name].localised_name}
        -- set up event to adjust request amount as items come in
        if not event.is_enabled('update_request_counts', player.index) then
          event.enable('update_request_counts', player.index)
        end
        -- add to player table
        player_table.logistics_requests[name] = stack_size
        -- close gui
        gui.close(player, player_table)
        -- update request counts immediately
        update_request_counts{player_index=player.index}
        return
      end
    end
  elseif type == 'unavailable' then
    if shift then
      if player.cheat_mode then
        player.clean_cursor()
        player.cursor_stack.set_stack{name=name, count=stack_size}
        gui.close(player, player_table)
      else
        player.print{'qis-message.not-in-cheat-mode'}
      end
    else
      set_ghost_cursor()
      gui.close(player, player_table)
    end
  end
end

-- get the slot type (inventory, logistics, unavailable) from the slot's style
local function extract_slot_type(elem)
  return elem.style.name:gsub('_active', ''):gsub('qis_slot_button_(.+)', '%1')
end

-- -----------------------------------------------------------------------------
-- GUI

-- ----------------------------------------
-- GUI CONDITIONAL HANDLERS

local function input_nav(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  -- check GUI state in case we're inputting a custom request amount
  if gui_data.state == 'select_result' then
    local elems = gui_data.results_table.children
    local columns = player.mod_settings['qis-column-count'].value
    -- get offset
    local offset = ({up=-columns, left=-1, down=columns, right=1})[e.input_name:gsub('qis%-nav%-', '')]
    if offset then
      -- reset style and apply offset
      local selected_index = gui_data.selected_index
      elems[selected_index].style = elems[selected_index].style.name:gsub('qis_active', 'qis')
      selected_index = util.clamp(selected_index + offset, 1, #elems)
      -- set new style and save new offset
      elems[selected_index].style = elems[selected_index].style.name:gsub('qis', 'qis_active')
      gui_data.selected_index = selected_index
      -- update item name in textfield
      gui_data.search_textfield.text = player_table.dictionary.translations[string_gsub(elems[selected_index].sprite, 'item/', '')]
      -- scroll
      gui_data.results_scroll.scroll_to_element(elems[selected_index])
    end
  end
end

local function input_confirm(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  local elem = gui_data.results_table.children[gui_data.selected_index]
  take_item_action(player, player_table, elem.sprite:gsub('(.+)/', ''), elem.number or 0, extract_slot_type(elem), e.input_name == 'qis-nav-shift-confirm',
    e.input_name == 'qis-nav-control-confirm')
end

local function result_button_clicked(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  take_item_action(player, player_table, e.element.sprite:gsub('(.+)/', ''), e.element.number or 0, extract_slot_type(e.element), e.shift, e.control)
end

local function search_textfield_text_changed(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  local results_table = gui_data.results_table
  if gui_data.state == 'select_result' then
    -- deselect button and reset selected index
    gui_data.state = 'search'
    local style = results_table.children[gui_data.selected_index].style
    style = style.name:gsub('qis_active', 'qis')
    gui_data.selected_index = 1
  end
  if e.element.text == '' then results_table.clear(); return end
  -- update results
  search_for_items(player, player_table, e.element.text, results_table)
end

local function search_textfield_confirmed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  local results_table = gui_data.results_table
  local results_count = #results_table.children
  if results_count > 0 then
    -- setup
    gui_data.state = 'select_result'
    gui_data.selected_index = 1
    results_table.focus()
    game.get_player(e.player_index).opened = gui_data.results_table
    -- enable gui navigation events
    event.enable_group('gui.nav', e.player_index)
    -- set initial selection
    results_table.children[1].style = string_gsub(results_table.children[1].style.name, 'qis', 'qis_active')
    gui_data.query = gui_data.search_textfield.text
    gui_data.search_textfield.text = player_table.dictionary.translations[string_gsub(results_table.children[1].sprite, 'item/', '')]
  end
end

local function search_textfield_clicked(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  if gui_data.state == 'select_result' then
    -- reset to searching
    local children = gui_data.results_table.children
    local selected_index = gui_data.selected_index
    -- deselect selected button and reset flag
    children[selected_index].style = children[selected_index].style.name:gsub('qis_active', 'qis')
    gui_data.state = 'search'
    gui_data.selected_index = 1
    -- set textfield text and focus it
    gui_data.search_textfield.text = gui_data.query
    gui_data.query = nil
    gui_data.search_textfield.focus()
    game.get_player(e.player_index).opened = gui_data.search_textfield
    -- disable navigation events
    event.disable_group('gui.nav', e.player_index)
  end
end

local function input_textfield_text_changed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  local element = e.element
  local text = element.text
  if text == '' or tonumber(text) < 1 then
    element.style = 'qis_invalid_textfield'
  else
    element.style = 'short_number_textfield'
    gui_data.last_request_amount = text
  end
end

local function input_textfield_confirmed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  local last_value = gui_data.last_request_amount
  if e.element.text ~= last_value then
    e.element.text = last_value
    e.element.style = 'short_number_textfield'
  end
  take_item_action(game.get_player(e.player_index), player_table, gui_data.selected_item_name, tonumber(last_value), 'logistics', nil, nil,
    gui_data.slot_to_insert)
end

local function gui_closed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  if e.element == gui_data.search_textfield and gui_data.state == 'search' then
    gui.close(game.get_player(e.player_index), player_table)
  elseif e.element == gui_data.results_table and gui_data.state == 'select_result' then
    search_textfield_clicked(e)
  elseif e.element == gui_data.input_textfield and gui_data.state == 'input_request_amount' then
    gui_data.results_scroll.visible = true
    gui_data.input_flow.visible = false
    game.get_player(e.player_index).opened = gui_data.results_table
    gui_data.state = 'select_result'
  end
end

local function gui_opened(e)
  -- if it's not one of our elements, close everything

end

event.register_conditional{
  search_textfield_text_changed = {id=defines.events.on_gui_text_changed, handler=search_textfield_text_changed, group={'gui', 'gui.search_textfield'}},
  search_textfield_confirmed = {id=defines.events.on_gui_confirmed, handler=search_textfield_confirmed, group={'gui', 'gui.search_textfield'}},
  search_textfield_clicked = {id=defines.events.on_gui_click, handler=search_textfield_clicked, group={'gui', 'gui.search_textfield'}},
  input_nav = {id={'qis-nav-up', 'qis-nav-left', 'qis-nav-down', 'qis-nav-right'}, handler=input_nav, group={'gui', 'gui.nav'}, options={suppress_logging=true}},
  input_confirm = {id={'qis-nav-confirm', 'qis-nav-shift-confirm', 'qis-nav-control-confirm'}, handler=input_confirm, group={'gui', 'gui.nav'},
    options={suppress_logging=true}},
  result_button_clicked = {id=defines.events.on_gui_click, handler=result_button_clicked, group='gui', options={match_filter_strings=true}},
  input_textfield_text_changed = {id=defines.events.on_gui_text_changed, handler=input_textfield_text_changed, group={'gui', 'gui.input_textfield'}},
  input_textfield_confirmed = {id=defines.events.on_gui_confirmed, handler=input_textfield_confirmed, group={'gui', 'gui.input_textfield'}},
  gui_closed = {id=defines.events.on_gui_closed, handler=gui_closed, group='gui'},
  gui_opened = {id=defines.events.on_gui_opened, handler=gui_opened},
  update_request_counts = {id=defines.events.on_player_main_inventory_changed, handler=update_request_counts, group={'gui'}, options={suppress_logging=true}}
}

-- ----------------------------------------
-- GUI MANAGEMENT

function gui.open(parent, player, settings)
  -- dimensions
  local pane_width = (40 * settings.columns) + 12
  local pane_height = settings.rows * 40

  -- window and textfield
  local window = parent.add{type='frame', name='qis_window', direction='vertical'}
  local textfield_def = {type='textfield', clear_and_focus_on_right_click=true, text='Search...'}
  local search_textfield
  if settings.location ~= 'bottom' then
    search_textfield = window.add(textfield_def)
    search_textfield.style.bottom_margin = 6
    search_textfield.style.width = pane_width
    window.style.bottom_padding = 8
  end

  local content_flow = window.add{type='flow'}
  content_flow.style.horizontal_spacing = 0

  -- results scrollpane
  local results_scroll = content_flow.add{type='scroll-pane', style='results_scroll_pane', vertical_scroll_policy='always'}
  results_scroll.style.width = pane_width
  results_scroll.style.height = pane_height
  local results_table = results_scroll.add{type='table', style='results_slot_table', column_count=settings.columns}

  -- amount input
  local input_flow = content_flow.add{type='flow', direction='vertical'}
  input_flow.style.width = pane_width
  input_flow.style.height = pane_height
  input_flow.visible = false
  input_flow.add{type='label', style='bold_label', caption={'qis-gui.enter-amount'}}
  local input_textfield = input_flow.add{type='textfield', numeric=true}
  input_textfield.style.width = 150

  -- textfield for bottom GUI
  if settings.location == 'bottom' then
    search_textfield = window.add(textfield_def)
    search_textfield.style.top_margin = 6
    search_textfield.style.width = pane_width
    window.style.top_padding = 8
    window.style.bottom_padding = 6
    -- position GUI
    window.location = {x=0, y=player.display_resolution.height - ((pane_height + 60) * player.display_scale)}
  elseif settings.location == 'center' then
    window.force_auto_center()
  end

  -- events
  search_textfield.select_all()
  search_textfield.focus()
  event.enable_group('gui.search_textfield', player.index, search_textfield.index)
  event.enable('result_button_clicked', player.index)
  event.enable_group('gui.input_textfield', player.index, input_textfield.index)
  event.enable('gui_closed', player.index, {search_textfield.index, results_table.index, input_textfield.index})

  return {window=window, search_textfield=search_textfield, results_scroll=results_scroll, results_table=results_table, input_flow=input_flow,
          input_textfield=input_textfield, selected_index=1, state='search', last_request_amount=''}
end

function gui.close(player, player_table)
  event.disable_group('gui', player.index)
  player_table.gui.window.destroy()
  player_table.gui = nil
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

local function close_guis_then_translate(e)
  local player = game.get_player(e.player_index)
  close_player_guis(player, global.players[e.player_index])
  translation.start(player, 'items', global.__lualib.translation.translation_data)
end

event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
  build_prototype_data()
  translate_for_all_players()
  event.register(translation.retranslate_all_event, close_guis_then_translate)
end)

event.on_load(function()
  event.register(translation.retranslate_all_event, close_guis_then_translate)
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
  close_guis_then_translate(e)
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.register(translation.finish_event, function(e)
  local player_table = global.players[e.player_index]
  player_table.flags.can_open_gui = true
  player_table.dictionary = {
    lookup = e.lookup,
    translations = e.translations
  }
  if player_table.flags.tried_to_open_gui then
    player_table.flags.tried_to_open_gui = false
    game.get_player(e.player_index).print{'qis-message.translation-finished'}
  end
end)

event.register('qis-search', function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  if gui_data and gui_data.state == 'select_result' then
    search_textfield_clicked(e)
  elseif not gui_data then
    if player_table.flags.can_open_gui then
      local mod_settings = player.mod_settings
      local location_setting = mod_settings['qis-'..(player.controller_type == defines.controllers.editor and 'editor' or 'default')..'-location'].value
      local parent = location_setting == 'mod gui' and mod_gui.get_frame_flow(player) or player.gui.screen
      gui_data = gui.open(parent, player, {location=location_setting, rows=mod_settings['qis-row-count'].value,
        columns=mod_settings['qis-column-count'].value})
      player.opened = gui_data.search_textfield
      player_table.gui = gui_data
    else
      player.print{'qis-message.translation-not-finished'}
      player_table.flags.tried_to_open_gui = true
    end
  end
end)

-- -----------------------------------------------------------------------------
-- MIGRATIONS

-- table of migration functions
local migrations = {
  ['1.1.0'] = function()
    global.dictionaries = nil
    global.__translation = {
      dictionary_count = 0,
      players = {}
    }
    for i,_ in pairs(game.players) do
      global.players[i].flags.can_open_gui = false
    end
  end,
  ['1.2.0'] = function()
    local to_deregister = {
      search_textfield_text_changed = search_textfield_text_changed,
      search_textfield_confirmed = search_textfield_confirmed,
      input_nav = input_nav,
      input_confirm = input_confirm,
      result_button_clicked = result_button_clicked
    }
    global.conditional_event_registry = nil
    global.__translation = nil
    global.__lualib.translation = {
      dictionary_count = 0,
      players = {}
    }
    -- deregister GUI events so they can be created with the new format
    for n,t in pairs(global.__lualib.event) do
      -- so the next code doesn't crash
      t.gui_filters = {}
      -- completely nuke all gui-related conditional events
      if to_deregister[n] then
        event.disable(to_deregister[n], n)
      end
    end
    -- destroy any open GUIs
    for _,t in pairs(global.players) do
      t.search = nil
      if t.gui then
        t.gui.window.destroy()
        t.gui = nil
      end
    end
  end,
  ['1.3.0'] = function()
    for _,t in pairs(global.players) do
      -- remove flag as it as been moved to gui_data
      t.flags.selecting_result = nil
      -- reset translation module data
      global.__lualib.translation = {
        active_translations_count = 0,
        players = {}
      }
      for i,_ in pairs(game.players) do
        global.__lualib.translation.players[i] = {
          active_translations = {},
          active_translations_count = 0,
          next_index = 1,
          string_registry = {},
          strings = {},
          strings_len = 0
        }
      end
    end
  end
}

-- handle migrations
event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    -- close open GUIs
    for i,p in pairs(game.players) do
      local player_table = global.players[i]
      close_player_guis(p, player_table)
    end
    -- retranslate for all players
    translation.cancel_all()
    build_prototype_data()
    translate_for_all_players()
  end
end)