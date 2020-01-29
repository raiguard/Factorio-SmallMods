-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

 -- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')
if __DebugAdapter then
  script.on_event('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local translation = require('lualib/translation')

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
      can_open_gui = false
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
  local requests = player_table.logistics_requests
  local inv_contents = player.get_main_inventory().get_contents()
  if player.cursor_stack and player.cursor_stack.valid_for_read then
    local stack = player.cursor_stack
    inv_contents[stack.name] = stack.count + (inv_contents[stack.name] or 0)
  end
  for name,count in pairs(requests) do -- for each request we're keeping track of
    if (inv_contents[name] or 0) >= count then
      -- set logistic request
      local get_slot = character.get_request_slot
      for i=1,character.request_slot_count do
        local slot = get_slot(i)
        if slot and slot.name == name then
          character.clear_request_slot(i)
          requests[name] = nil
          break
        end
      end
    end
  end
  if table_size(requests) == 0 then
    -- deregister this event
    event.deregister({defines.events.on_player_main_inventory_changed, defines.events.on_player_cursor_stack_changed}, update_request_counts,
      'update_request_counts', player.index)
  end
end

local function search_for_items(player, query)
  local player_table = global.players[player.index]
  local player_settings = player.mod_settings
  local show_hidden = player_settings['qis-search-hidden'].value
  local results = {}
  if player_settings['qis-fuzzy-search'].value then -- fuzzy search
    query = query:gsub('.', '%1.*')
  end
  query = string_lower(query)
  -- search dictionary first, then iterate through that to decrease the number of API calls
  local search_results = {}
  local search_table = player_table.dictionary.searchable
  local item_data = global.item_data
  for i=1,#search_table do
    local t = search_table[i]
    local internal = t.internal
    if string_match(string_lower(t.translated), query) then
      search_results[internal] = item_data[internal]
    end
  end
  -- map editor
  if player.controller_type == defines.controllers.editor then
    local contents = player.get_main_inventory().get_contents()
    for name,t in pairs(search_results) do
      results[name] = {count=contents[name], tooltip=t.localised_name, type='inventory', sprite='item/'..name}
    end
  else
    -- player inventory
    if player_settings['qis-search-inventory'].value then
      local contents = player.get_main_inventory().get_contents()
      for name,t in pairs(search_results) do
        if not results[name] and contents[name] and (show_hidden or not t.hidden) then
          results[name] = {count=contents[name], tooltip=t.localised_name, type='inventory', sprite='item/'..name}
        end
      end
    end
    if player.character then
      local character = player.character
      -- logistic network(s)
      if player_settings['qis-search-logistics'].value then
        for _,point in ipairs(character.get_logistic_point()) do
          local network = point.logistic_network
          if network.valid then
            local contents = point.logistic_network.get_contents()
            for name,t in pairs(search_results) do
              if not results[name] and contents[name] and (show_hidden or not t.hidden) then
                results[name] = {count=contents[name], tooltip=t.localised_name, type='logistics', sprite='item/'..name}
              end
            end
          end
        end
      end
    end
    -- unavailable
    if player_settings['qis-search-unavailable'].value then
      for name,t in pairs(search_results) do
        if not results[name] and (show_hidden or not t.hidden) then
          results[name] = {tooltip=t.localised_name, type='unavailable', sprite='item/'..name}
        end
      end
    end
  end
  return results
end

-- take action on the selected item
local function take_item_action(player, name, count, type, shift)
  local prototype = game.item_prototypes[name]
  local stack_size = prototype.stack_size
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
  elseif type == 'logistics' and player.character and player.character.valid then
    local character = player.character
    if shift then
      set_ghost_cursor()
    else -- request from logistic network
      local get_slot = character.get_request_slot
      for i=1,character.request_slot_count do
        if get_slot(i) == nil then
          character.set_request_slot({name=name, count=stack_size}, i)
          player.print{'qis-message.request-from-logistic-network', stack_size, global.item_data[name].localised_name}
          -- set up event to adjust request amount as items come in
          if not event.is_registered('update_request_counts', player.index) then
            event.register({defines.events.on_player_main_inventory_changed, defines.events.on_player_cursor_stack_changed}, update_request_counts,
              {name='update_request_counts', player_index=player.index})
          end
          -- add to player table
          global.players[player.index].logistics_requests[name] = stack_size
          return
        elseif get_slot(i).name == name then
          player.print{'qis-message.already-requested-item', global.item_data[name].localised_name}
          return
        end
      end
    end
  elseif type == 'unavailable' then
    set_ghost_cursor()
  end
end

-- get the slot type (inventory, logistics, unavailable) from the slot's style
local function extract_slot_type(elem)
  return elem.style.name:gsub('qis_(.+)_result_slot_button', '%1'):gsub('active_', '')
end

-- -----------------------------------------------------------------------------
-- GUI

-- ----------------------------------------
-- GUI CONDITIONAL HANDLERS

local function input_nav(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
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

local function input_confirm(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  local elem = gui_data.results_table.children[gui_data.selected_index]
  take_item_action(player, elem.sprite:gsub('(.+)/', ''), elem.number or 0, extract_slot_type(elem), e.input_name == 'qis-nav-shift-confirm',
    e.input_name == 'qis-nav-control-confirm')
  -- close GUI
  event.raise(defines.events.on_gui_closed, {element=gui_data.window, gui_type=16, player_index=e.player_index, tick=game.tick})
end

local function result_button_clicked(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  take_item_action(player, e.element.sprite:gsub('(.+)/', ''), e.element.number or 0, extract_slot_type(e.element), e.shift)
  -- close GUI
  event.raise(defines.events.on_gui_closed, {element=gui_data.window, gui_type=16, player_index=e.player_index, tick=game.tick})
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
  local i = 0
  local children = table.deepcopy(results_table.children)
  for _,t in pairs(search_for_items(player, string.lower(e.element.text))) do
    i = i + 1
    local elem = children[i]
    if not elem then -- create button
      results_table.add{type='sprite-button', name='qis_result_button_'..i, style='qis_'..t.type..'_result_slot_button', sprite=t.sprite, number=t.count,
                        tooltip=t.tooltip}
    else -- update button
      elem.sprite = t.sprite
      elem.number = t.count
      elem.tooltip = t.tooltip
      elem.style = 'qis_'..t.type..'_result_slot_button'
      children[i] = nil
    end
  end
  -- delete remaining elements
  for _,elem in pairs(children) do
    elem.destroy()
  end
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
    gui_data.results_table.focus()
    -- register events for selecting an item
    event.register({'qis-nav-up', 'qis-nav-left', 'qis-nav-down', 'qis-nav-right'}, input_nav, {name='input_nav', player_index=e.player_index})
    event.register({'qis-nav-confirm', 'qis-nav-shift-confirm', 'qis-nav-control-confirm'}, input_confirm, {name='input_confirm', player_index=e.player_index})
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
    -- deregister navigation events
    event.deregister({'qis-nav-up', 'qis-nav-left', 'qis-nav-down', 'qis-nav-right'}, input_nav, 'input_nav', e.player_index)
    event.deregister({'qis-nav-confirm', 'qis-nav-alt-confirm'}, input_confirm, 'input_confirm', e.player_index)
  end
end

local function gui_closed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui
  if gui_data.state == 'search' then
    gui.destroy(gui_data.window, e.player_index)
    player_table.gui = nil
  elseif gui_data.state == 'select_result' then
    search_textfield_clicked(e)
  end
end

local handlers = {
  search_textfield_text_changed = search_textfield_text_changed,
  search_textfield_confirmed = search_textfield_confirmed,
  search_textfield_clicked = search_textfield_clicked,
  input_nav = input_nav,
  input_confirm = input_confirm,
  result_button_clicked = result_button_clicked,
  gui_closed = gui_closed
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
  event.load_conditional_handlers{
    update_request_counts = update_request_counts
  }
end)

-- ----------------------------------------
-- GUI MANAGEMENT

function gui.create(parent, player, settings)
  -- dimensions
  local pane_width = (40 * settings.columns) + 12
  local pane_height = settings.rows * 40
  -- elements
  local window = parent.add{type='frame', name='qis_window', direction='vertical'}
  local textfield_def = {type='textfield', name='qis_search_textfield', clear_and_focus_on_right_click=true, text='Search...'}
  local search_textfield
  if settings.location ~= 'bottom' then
    search_textfield = window.add(textfield_def)
    search_textfield.style.bottom_margin = 6
    search_textfield.style.width = pane_width
    window.style.bottom_padding = 8
  end
  local results_scroll = window.add{type='scroll-pane', name='qis_results_scroll_pane', style='results_scroll_pane', vertical_scroll_policy='always'}
  results_scroll.style.width = pane_width
  results_scroll.style.height = pane_height
  local results_table = results_scroll.add{type='table', name='qis_results_table', style='results_slot_table', column_count=settings.columns}
  if settings.location == 'bottom' then
    search_textfield = window.add(textfield_def)
    search_textfield.style.top_margin = 6
    search_textfield.style.width = pane_width
    window.style.top_padding = 8
    window.style.bottom_padding = 6
    -- position GUI
    window.location = {x=0, y=player.display_resolution.height-((pane_height + 60)*player.display_scale)}
  elseif settings.location == 'center' then
    window.force_auto_center()
  end
  -- events
  search_textfield.select_all()
  search_textfield.focus()
  event.on_gui_text_changed(search_textfield_text_changed, {name='search_textfield_text_changed', player_index=player.index, gui_filters=search_textfield})
  event.on_gui_confirmed(search_textfield_confirmed, {name='search_textfield_confirmed', player_index=player.index, gui_filters=search_textfield})
  event.on_gui_click(search_textfield_clicked, {name='search_textfield_clicked', player_index=player.index, gui_filters=search_textfield})
  event.on_gui_click(result_button_clicked, {name='result_button_clicked', player_index=player.index, gui_filters='qis_result_button'})
  event.on_gui_closed(gui_closed, {name='gui_closed', player_index=player.index, gui_filters={search_textfield, results_scroll}})
  return {window=window, search_textfield=search_textfield, results_scroll=results_scroll, results_table=results_table, selected_index=1}
end

function gui.destroy(window, player_index)
  -- deregister all GUI events if needed
  for cn,h in pairs(handlers) do
    event.deregister_conditional(h, cn, player_index)
  end
  window.destroy()
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
  build_prototype_data()
  translate_for_all_players()
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.on_player_joined_game(function(e)
  translation.start(game.get_player(e.player_index), 'items', global.__lualib.translation.translation_data)
  -- close open GUIs
  local player_table = global.players[e.player_index]
  player_table.flags.can_open_gui = false
  if player_table.gui then -- close the open GUI
    gui.close(player_table.gui.window, e.player_index)
  end
end)

event.register(translation.finish_event, function(e)
  local player_table = global.players[e.player_index]
  player_table.flags.can_open_gui = true
  player_table.dictionary = {
    lookup = e.lookup,
    searchable = e.searchable,
    translations = e.translations
  }
  if player_table.flags.tried_to_open_gui then
    player_table.flags.tried_to_open_gui = false
    game.get_player(e.player_index).print{'qis-message.translation-finished'}
  end
end)

event.register(translation.retranslate_all_event, translate_for_all_players)

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
      gui_data = gui.create(parent, player, {location=location_setting, rows=mod_settings['qis-row-count'].value,
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
  ['1.1.0'] = function(e)
    global.dictionaries = nil
    global.__translation = {
      dictionary_count = 0,
      players = {}
    }
    for i,_ in pairs(game.players) do
      global.players[i].flags.can_open_gui = false
    end
  end,
  ['1.2.0'] = function(e)
    local to_deregister = {
      search_textfield_text_changed = search_textfield_text_changed,
      search_textfield_confirmed = search_textfield_confirmed,
      input_nav = input_nav,
      input_confirm = input_confirm,
      result_button_clicked = result_button_clicked
    }
    global.__lualib.translation.build_data = nil
    -- deregister GUI events so they can be created with the new format
    for n,t in pairs(global.__lualib.event) do
      -- so the next code doesn't crash
      t.gui_filters = {}
      -- completely nuke all gui-related conditional events
      if to_deregister[n] then
        event.deregister_conditional(to_deregister[n], n)
      end
    end
    -- destroy any open GUIs
    for i,t in pairs(global.players) do
      t.search = nil
      if t.gui then
        t.gui.window.destroy()
        t.gui = nil
      end
    end
  end,
  ['1.3.0'] = function(e)
    for _,t in pairs(global.players) do
      -- remove flag as it as been moved to gui_data
      t.flags.selecting_result = nil
    end
  end
}

-- returns true if v2 is newer than v1, false if otherwise
local function compare_versions(v1, v2)
  local v1_split = util.split(v1, '.')
  local v2_split = util.split(v2, '.')
  for i=1,#v1_split do
    if v1_split[i] < v2_split[i] then
      return true
    end
  end
  return false
end

-- handle migrations
event.on_configuration_changed(function(e)
  local changes = e.mod_changes[script.mod_name]
  if changes then
    local old = changes.old_version
    if old then
      -- version migrations
      local migrate = false
      for v,f in pairs(migrations) do
        if migrate or compare_versions(old, v) then
          migrate = true
          log('Applying migration: '..v)
          f(e)
        end
      end
    end
  end
  -- retranslate for all players
  translation.cancel_all()
  build_prototype_data()
  translate_for_all_players()
  -- close open GUIs
  for i,_ in pairs(game.players) do
    local player_table = global.players[i]
    player_table.flags.can_open_gui = false
    if player_table.gui then -- close the open GUI
      gui.close(player_table.gui.window, i)
    end
  end
end)