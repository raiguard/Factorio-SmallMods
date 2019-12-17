-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

local event = require('lualib/event')
local util = require('lualib/util')

local mod_gui = require('mod-gui')
local translation_started_event = event.generate_id('translation_started')

local gui = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- setup player global table and GUI
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
      prototype_dictionary[prototype.localised_name[1]] = {type='item', name=prototype.name}
    end
    for _,prototype in pairs(game.equipment_prototypes) do
      prototype_dictionary[prototype.localised_name[1]] = {type='equipment', name=prototype.name}
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
end

local function build_search_results(player, dictionary, settings, search)
  local settings = player.mod_settings
  local results = {}
  local function add_if_match(name, count, result_type)
    local dict_entry = dictionary[name]
    if not results[name] and dict_entry and dict_entry.name:match(search) then
        results[name] = {count=count, tooltip=dict_entry.localised_name, type=result_type, sprite=dict_entry.type..'/'..name}
    end
  end
  if player.controller_type == defines.controllers.editor then
    -- show all items
    -- local inv_contents = player.get_main_inventory().get_contents()
    for internal,_ in pairs(dictionary) do
      add_if_match(internal, nil, 'inventory')
    end
  else
    -- player inventory
    if settings['qis-search-inventory'].value then
      local inv_contents = player.get_main_inventory().get_contents()
      for name,count in pairs(inv_contents) do
        add_if_match(name, count, 'inventory')
      end
    end
    if player.character then
      local character = player.character
      -- logistic network(s)
      if settings['qis-search-logistics'].value then
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
      if settings['qis-search-crafting'].value then
        for name,recipe in pairs(player.force.recipes) do
          local count = player.get_craftable_count(recipe)
          if count > 0 then
            add_if_match(name, count, 'crafting')
          end
        end
      end
    end
    -- unavailable
    if settings['qis-search-unavailable'].value then
      for internal,_ in pairs(dictionary) do
        add_if_match(internal, nil, 'unavailable')
      end
    end
  end
  return results
end

local function update_results_table(player, player_table, gui_data, results_table, search_query)
end

-- -----------------------------------------------------------------------------
-- GUI

-- ----------------------------------------
-- GUI HANDLERS

local function input_nav(e)
  local player_table = util.player_table(e)
  local gui_data = player_table.gui
  local elems = gui_data.results_table.children
  -- get offset
  local nav_direction_to_offset = {up=-6, left=-1, down=6, right=1}
  local offset = nav_direction_to_offset[e.input_name:gsub('qis%-nav%-', '')]
  if offset then
    -- reset style and apply offset
    local selected_index = gui_data.selected_index
    elems[selected_index].style = elems[selected_index].style.name:gsub('qis_active', 'qis')
    selected_index = math.clamp(selected_index + offset, 1, #elems)
    -- set new style and save new offset
    elems[selected_index].style = elems[selected_index].style.name:gsub('qis', 'qis_active')
    gui_data.selected_index = selected_index
  end
end

local function input_confirm(e)
  local player_table = util.player_table(e)
  local gui_data = player_table.gui
  local elems = gui_data.results_table.children
  -- get prototype name of item to take action on
  local prototype_name = elems[gui_data.selected_index].sprite:gsub('(.+)/', '')
  util.log(prototype_name, true)
  -- close GUI (which resets settings and flag)
  event.raise(defines.events.on_gui_closed, {element=gui_data.window, gui_type=16, player_index=e.player_index, tick=game.tick})
end

local function result_button_clicked(e)
  util.log(e)
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
  for _,t in pairs(build_search_results(player, player_table.dictionary, gui_data.settings, string.lower(e.element.text))) do
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
    -- get prototype name of item to take action on
    local prototype_name = results_table.children[gui_data.selected_index].sprite:gsub('(.+)/', '')
    util.log(prototype_name, true)
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

function gui.create(parent, player)
  local window = parent.add{type='frame', name='qis_window', style='dialog_frame', direction='vertical'}
  local search_textfield = window.add{type='textfield', name='qis_search_textfield', style='qis_search_textfield', lose_focus_on_confirm=true,
                                      clear_and_focus_on_right_click=true, text='Search...'}
  search_textfield.select_all()
  search_textfield.focus()
  event.on_gui_text_changed(search_textfield_text_changed, {name='search_textfield_text_changed', player_index=player.index, gui_filters=search_textfield})
  event.on_gui_confirmed(search_textfield_confirmed, {name='search_textfield_confirmed', player_index=player.index, gui_filters=search_textfield})
  local results_scroll = window.add{type='scroll-pane', name='qis_results_scroll_pane', style='results_scroll_pane', vertical_scroll_policy='always'}
  local results_table = results_scroll.add{type='table', name='qis_results_table', style='results_slot_table', column_count=6}
  return {window=window, search_textfield=search_textfield, results_table=results_table, selected_index=1}
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
-- EVENT HANDLERS

-- on init
event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
end)

-- on load
event.on_load(function()
  -- rebuild all connected player dictionaries on the first tick (for singleplayer)
  event.register(defines.events.on_tick, build_dictionary)
end)

-- when a player is created
event.register(defines.events.on_player_created, function(e)
  local player = game.players[e.player_index]
  setup_player(player)
end)

-- when a player joins a game
event.register(defines.events.on_player_joined_game, function(e)
  build_dictionary(e)
end)

-- when a string gets translated
event.register(defines.events.on_string_translated, function(e)
  local player_table = util.player_table(e)
  local dictionary = player_table.dictionary
  local prototype_dictionary = player_table.prototype_dictionary
  if e.translated and player_table.flags.building_dictionary then
    local data = player_table.prototype_dictionary[e.localised_string[1]]
    dictionary[data.name] = {type=data.type, name=string.lower(e.result), localised_name=e.localised_string}
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
    gui_data = gui.create(mod_gui.get_frame_flow(player), player)
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