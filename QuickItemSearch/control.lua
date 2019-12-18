-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

local event = require('lualib/event')
local util = require('lualib/util')

local mod_gui = require('mod-gui')
local translation_started_event = event.generate_id('translation_started')

local gui = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- setup player global table
local function setup_player(player)
  local data = {
    dictionary = {},
    flags = {
      building_dictionary = false,
      selecting_result = false
    }
  }
  global.players[player.index] = data
end

-- builds table of search results by searching the player's dictionary
local function build_search_results(player, dictionary, search)
  local player_settings = player.mod_settings
  local results = {}
  local search_split = string.split(search, ' ')
  local search_count = #search_split
  local show_hidden = player_settings['qis-search-hidden'].value
  local function add_if_match(name, count, result_type)
    local dict_entry = dictionary[name]
    if not results[name] and dict_entry then
      if dict_entry.hidden and not show_hidden then return end
      local dict_name = dict_entry.name
      local matches = 0
      for _,str in ipairs(search_split) do
        if dict_name:match(str) then
          matches = matches + 1
        end
      end
      if matches == search_count then
        results[name] = {count=count, tooltip=dict_entry.localised_name, type=result_type, sprite=dict_entry.type..'/'..name}
      end
    end
  end
  if player.controller_type == defines.controllers.editor then
    -- show all items
    local inv_contents = player.get_main_inventory().get_contents()
    for internal,_ in pairs(dictionary) do
      add_if_match(internal, inv_contents[internal], 'inventory')
    end
  else
    -- player inventory
    if player_settings['qis-search-inventory'].value then
      local inv_contents = player.get_main_inventory().get_contents()
      for name,count in pairs(inv_contents) do
        add_if_match(name, count, 'inventory')
      end
    end
    if player.character then
      local character = player.character
      -- logistic network(s)
      if player_settings['qis-search-logistics'].value then
        for _,point in ipairs(character.get_logistic_point()) do
          local network = point.logistic_network
          if network.valid then
            for name,count in pairs(point.logistic_network.get_contents()) do
              add_if_match(name, count, 'logistics')
            end
          end
        end
      end
      -- crafting
      if player_settings['qis-search-crafting'].value then
        for name,recipe in pairs(player.force.recipes) do
          local count = player.get_craftable_count(recipe)
          if count > 0 then
            add_if_match(name, count, 'crafting')
          end
        end
      end
    end
    -- unavailable
    if player_settings['qis-search-unavailable'].value then
      for internal,_ in pairs(dictionary) do
        add_if_match(internal, nil, 'unavailable')
      end
    end
  end
  return results
end

local function take_item_action(player, name, count, type, alt)
  local prototype = game.item_prototypes[name]
  local stack_size = prototype.stack_size
  local function set_ghost_cursor()
    if prototype.place_result then
      player.cursor_ghost = name
    end
  end
  util.log(player.name..': '..name..'-'..count..' | '..type..' '..tostring(alt))
  if type == 'inventory' then
    if count == 0 and player.controller_type == defines.controllers.editor then -- editor
      player.cursor_stack.set_stack{name=name, count=stack_size}
    else
      player.cursor_stack.set_stack{name=name, count=player.get_main_inventory().remove{name=name, count=stack_size}}
    end
    -- 0.18:
    if player.controller_type == defines.controllers.editor and alt then
      player.print('set filters when 0.18 comes out!')
      -- local filters = player.infinity_inventory_filters
      -- local index = #filters + 1
      -- filters[index] = {name=name, count=stack_size, mode='exactly', index=index}
    end
  elseif type == 'logistics' and player.character and player.character.valid then
    local character = player.character
    if alt then
      set_ghost_cursor()
    else -- request from logistic network
      local get_slot = character.get_request_slot
      for i=1,character.request_slot_count do
        if get_slot(i) == nil then
          character.set_request_slot({name=name, count=stack_size}, i)
          player.print{'chat-message.request-from-logistic-network', stack_size, util.player_table(player).dictionary[name].name}
          return
        end
      end
    end
  elseif type == 'crafting' then
    if alt then -- craft five
      player.begin_crafting{recipe=name, count=5, silent=true}
    else -- craft all
      player.begin_crafting{recipe=name, count=count}
    end
  elseif type == 'unavailable' then
    set_ghost_cursor()
  end
end

local function extract_slot_type(elem)
  return elem.style.name:gsub('qis_(.+)_result_slot_button', '%1'):gsub('active_', '')
end

-- -----------------------------------------------------------------------------
-- LOCALISED DICTIONARY

-- builds the dictionary for one player or all players
local function build_dictionary(e)
  local function request_translations(player, player_table)
    event.raise(translation_started_event, {player_index=player.index})
    player_table.flags.building_dictionary = true
    player_table.finished_size_offset = 0
    player_table.dictionary = {}
    local prototype_dictionary = {}
    -- to avoid a crash, we just assemble the prototypes table first, then request translations for all of it at once
    for _,prototype in pairs(game.item_prototypes) do
      prototype_dictionary[prototype.localised_name[1]] = {type='item', prototype=prototype}
    end
    for _,prototype in pairs(game.equipment_prototypes) do
      prototype_dictionary[prototype.localised_name[1]] = {type='equipment', prototype=prototype}
    end
    -- request translations
    for name,_ in pairs(prototype_dictionary) do
      player.request_translation({name})
    end
    player_table.prototype_dictionary = prototype_dictionary
  end
  if e.player_index then -- when a player joins a game
    request_translations(util.get_player(e))
  else -- for all connected players
    for _,player in pairs(game.players) do
      if player.connected then
        request_translations(player, util.player_table(player))
      end
    end
    event.deregister(defines.events.on_tick, build_dictionary)
  end
  if e.name == 'rebuild-localised-dictionary' then
    game.print{'chat-message.rebuilt-localised-dictionary', util.get_player(e).name}
  end
end

-- when a string gets translated
event.register(defines.events.on_string_translated, function(e)
  local player_table = util.player_table(e)
  local dictionary = player_table.dictionary
  local prototype_dictionary = player_table.prototype_dictionary
  if e.translated and player_table.flags.building_dictionary then
    local data = player_table.prototype_dictionary[e.localised_string[1]]
    dictionary[data.prototype.name] = {type=data.type, name=string.lower(e.result), localised_name=e.localised_string, hidden=data.type == 'item' and data.prototype.has_flag('hidden') or false}
  else
    util.log('\''..string.gsub(e.localised_string[1], '(.+)%.', '')..'\' was not translated, and will not be searchable.')
    player_table.finished_size_offset = player_table.finished_size_offset + 1
  end
  if table_size(prototype_dictionary) - table_size(dictionary) - player_table.finished_size_offset == 0 then
    player_table.prototype_dictionary = nil
    player_table.finished_size_offset = nil
    player_table.flags.building_dictionary = false
  end
end)

-- when a player joins a game, rebuild their dictionary
event.register(defines.events.on_player_joined_game, build_dictionary)

-- -----------------------------------------------------------------------------
-- GUI

-- ----------------------------------------
-- GUI CONDITIONAL HANDLERS

local function input_nav(e)
  local player, player_table = util.get_player(e)
  local gui_data = player_table.gui
  local elems = gui_data.results_table.children
  local columns = player.mod_settings['qis-column-count'].value
  -- get offset
  local offset = ({up=-columns, left=-1, down=columns, right=1})[e.input_name:gsub('qis%-nav%-', '')]
  if offset then
    -- reset style and apply offset
    local selected_index = gui_data.selected_index
    elems[selected_index].style = elems[selected_index].style.name:gsub('qis_active', 'qis')
    selected_index = math.clamp(selected_index + offset, 1, #elems)
    -- set new style and save new offset
    elems[selected_index].style = elems[selected_index].style.name:gsub('qis', 'qis_active')
    gui_data.selected_index = selected_index
    -- scroll
    gui_data.results_scroll.scroll_to_element(elems[selected_index])
  end
end

local function input_confirm(e)
  local player, player_table = util.get_player(e)
  local gui_data = player_table.gui
  local elem = gui_data.results_table.children[gui_data.selected_index]
  take_item_action(player, elem.sprite:gsub('(.+)/', ''), elem.number or 0, extract_slot_type(elem), e.input_name == 'qis-nav-alt-confirm')
  -- close GUI
  event.raise(defines.events.on_gui_closed, {element=gui_data.window, gui_type=16, player_index=e.player_index, tick=game.tick})
end

local function result_button_clicked(e)
  local player, player_table = util.get_player(e)
  local gui_data = player_table.gui
  take_item_action(player, e.element.sprite:gsub('(.+)/', ''), e.element.number or 0, extract_slot_type(e.element), e.shift)
  -- close GUI
  event.raise(defines.events.on_gui_closed, {element=gui_data.window, gui_type=16, player_index=e.player_index, tick=game.tick})
end

local function search_textfield_text_changed(e)
  local player, player_table = util.get_player(e)
  local gui_data = player_table.gui
  local results_table = gui_data.results_table
  if player_table.flags.selecting_result then
    -- deselect button and reset selected index
    player_table.flags.selecting_result = false
    local style = results_table.children[gui_data.settings.selected_index].style
    style = style.name:gsub('qis_active', 'qis')
    gui_data.settings.selected_index = 1
  end
  if e.element.text == '' then results_table.clear(); return end
  -- update results
  local i = 0
  local children = table.deepcopy(results_table.children)
  for _,t in pairs(build_search_results(player, player_table.dictionary, string.lower(e.element.text))) do
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
  local player, player_table = util.get_player(e)
  local gui_data = player_table.gui
  local results_table = gui_data.results_table
  local results_count = #results_table.children
  if results_count == 1 then
    local elem = results_table.children[1]
    take_item_action(player, elem.sprite:gsub('(.+)/', ''), elem.number or 0, extract_slot_type(elem), e.shift)
    -- close GUI (which resets settings and flag)
    event.raise(defines.events.on_gui_closed, {element=gui_data.window, gui_type=16, player_index=e.player_index, tick=game.tick})
  elseif results_count > 1 then
    -- setup
    player_table.flags.selecting_result = true
    gui_data.selected_index = 1
    -- register events for selecting an item
    event.register({'qis-nav-up', 'qis-nav-left', 'qis-nav-down', 'qis-nav-right'}, input_nav, {name='input_nav', player_index=e.player_index})
    event.register({'qis-nav-confirm', 'qis-nav-alt-confirm'}, input_confirm, {name='input_confirm', player_index=e.player_index})
    event.on_gui_click(result_button_clicked, {name='result_button_clicked', player_index=e.player_index, gui_filters='qis_result_button'})
    -- set initial selection
    results_table.children[1].style = results_table.children[1].style.name:gsub('qis', 'qis_active')
  end
end

local handlers = {
  search_textfield_text_changed = search_textfield_text_changed,
  search_textfield_confirmed = search_textfield_confirmed,
  input_nav = input_nav,
  input_confirm = input_confirm
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- ----------------------------------------
-- GUI MANAGEMENT

function gui.create(parent, player, settings)
  -- dimensions
  local pane_width = (40 * settings.columns) + 12
  local pane_height = settings.rows * 40
  -- elements
  local window = parent.add{type='frame', name='qis_window', direction='vertical'}
  local textfield_def = {type='textfield', name='qis_search_textfield', lose_focus_on_confirm=true, clear_and_focus_on_right_click=true, text='Search...'}
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
  end
  -- textfield events
  search_textfield.select_all()
  search_textfield.focus()
  event.on_gui_text_changed(search_textfield_text_changed, {name='search_textfield_text_changed', player_index=player.index, gui_filters=search_textfield})
  event.on_gui_confirmed(search_textfield_confirmed, {name='search_textfield_confirmed', player_index=player.index, gui_filters=search_textfield})

  return {window=window, search_textfield=search_textfield, results_scroll=results_scroll, results_table=results_table, selected_index=1}
end

function gui.destroy(window, player_index)
  -- deregister all GUI events if needed
  local con_registry = global.conditional_event_registry
  for cn,h in pairs(handlers) do
    if con_registry[cn] then
      event.deregister(con_registry[cn].id, h, {name=cn, player_index=player_index})
    end
  end
  window.destroy()
end

-- -----------------------------------------------------------------------------
-- GENERAL

commands.add_command('rebuild-localised-dictionary', 'Rebuilds the specified player\'s localised dictionary.', build_dictionary)

-- on init
event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
  -- register event if we're coming into an existing game
  if game.tick > 0 then
    event.register(defines.events.on_tick, build_dictionary)
  end
end)

-- when a player is created
event.register(defines.events.on_player_created, function(e)
  local player = game.players[e.player_index]
  setup_player(player)
end)

event.register(translation_started_event, function(e)
  util.log('translation started!')
end)

event.register('qis-search', function(e)
  local player, player_table = util.get_player(e)
  local gui_data = player_table.gui
  if gui_data and player_table.flags.selecting_result == true then
    -- reset to searching
    local children = gui_data.results_table.children
    local selected_index = gui_data.selected_index
    -- deselect selected button and reset flag
    children[selected_index].style = children[selected_index].style.name:gsub('qis_active', 'qis')
    player_table.flags.selecting_result = false
    gui_data.selected_index = 1
    -- focus textfield
    gui_data.search_textfield.focus()
  elseif not gui_data then
    local mod_settings = player.mod_settings
    local location_setting = mod_settings['qis-'..(player.controller_type == defines.controllers.editor and 'editor' or 'default')..'-location'].value
    local parent = location_setting == 'mod gui' and mod_gui.get_frame_flow(player) or player.gui.screen
    gui_data = gui.create(parent, player, {location=location_setting, rows=mod_settings['qis-row-count'].value, columns=mod_settings['qis-column-count'].value})
    player.opened = gui_data.window
    player_table.gui = gui_data
  end
end)

event.register(defines.events.on_gui_closed, function(e)
  if e.gui_type == 16 and e.element.name == 'qis_window' then
    gui.destroy(e.element, e.player_index)
    local player_table = util.player_table(e)
    player_table.flags.selecting_result = false
    player_table.gui = nil
  end
end)