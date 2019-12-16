-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

local event = require('lualib/event')
local util = require('lualib/util')

local mod_gui = require('mod-gui')
local translation_started_event = event.generate_id('translation_started')
local translation_finished_event = event.generate_id('translation_finished')

local gui = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- setup player global table and GUI
local function setup_player(player)
  local data = {
    dictionary = {},
    flags = {
      building_dictionary = false
    },
    gui = {
      settings = {
        inventory = true,
        logistics = true,
        crafting = true,
        unavailable = false,
        selected_index = 1
      }
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

-- -----------------------------------------------------------------------------
-- GUI

-- ----------------------------------------
-- GUI HANDLERS

local function search_textfield_text_changed(e)
  local player, player_table = util.get_player(e)
  if not player_table.flags.building_dictionary then
    local gui_data = player_table.gui
    local results_table = gui_data.elems.results_table
    local settings = gui_data.settings
    results_table.clear()
    if e.element.text == '' then return end
    local dictionary = player_table.dictionary
    local search = string.lower(e.element.text)
    local results = {}
    local i = 0
    if player.controller_type == defines.controllers.editor then
      -- show all items
      local inv_contents = player.get_main_inventory().get_contents()
      for internal,localized in pairs(dictionary) do
        local dict_entry = dictionary[internal]
        if dict_entry and dict_entry.name:match(search) then
            i = i + 1
            results_table.add{type='sprite-button', name='qis_result_button_'..i, style='qis_inventory_result_slot_button',
                              sprite=dict_entry.type..'/'..internal, number=inv_contents[internal]}
            results[internal] = 0
        end
      end
    else
      -- player inventory
      if settings.inventory then
        local inv_contents = player.get_main_inventory().get_contents()
        for name,count in pairs(inv_contents) do
          local dict_entry = dictionary[name]
          if dict_entry and dict_entry.name:match(search) then
            i = i + 1
            results_table.add{type='sprite-button', name='qis_result_button_'..i, style='qis_inventory_result_slot_button', sprite=dict_entry.type..'/'..name,
                              number=count}
            results[name] = count
          end
        end
      end
      if player.character then
        local character = player.character
        -- logistic network(s)
        if settings.logistics then
          for _,point in ipairs(character.get_logistic_point()) do
            local network = point.logistic_network
            if network.valid then
              for name,count in pairs(point.logistic_network.get_contents()) do
                local dict_entry = dictionary[name]
                if not results[name] and dict_entry and dict_entry.name:match(search) then
                  i = i + 1
                  results_table.add{type='sprite-button', name='qis_result_button_'..i, style='qis_logistics_result_slot_button', sprite=dict_entry.type..'/'..name,
                                    number=count}
                  results[name] = count
                end
              end
            end
          end
        end
        -- crafting
        if settings.crafting then
          for name,recipe in pairs(player.force.recipes) do
            local dict_entry = dictionary[name]
            if not results[name] and dict_entry and dict_entry.name:match(search) then
              local count = player.get_craftable_count(recipe)
              if count > 0 then
                i = i + 1
                results_table.add{type='sprite-button', name='qis_result_button_'..i, style='qis_crafting_result_slot_button', sprite=dict_entry.type..'/'..name,
                                  number=count}
                results[name] = count
              end
            end
          end
        end
      end
      -- unavailable
      if settings.unavailable then
        for internal,localized in pairs(dictionary) do
          local dict_entry = dictionary[internal]
          if not results[internal] and dict_entry and dict_entry.name:match(search) then
              i = i + 1
              results_table.add{type='sprite-button', name='qis_result_button_'..i, style='qis_unavailable_result_slot_button', sprite=dict_entry.type..'/'..internal}
              results[internal] = 0
          end
        end
      end
    end
  end
end

local function search_textfield_confirmed(e)
  util.log(e)
end

local function inventory_checkbox_state_changed(e)
  local player, player_table = util.get_player(e)
  player_table.gui.settings.inventory = e.element.state
  search_textfield_text_changed{tick=game.tick, player_index=e.player_index, element=player_table.gui.elems.search_textfield}
end

local function logistics_checkbox_state_changed(e)
  local player, player_table = util.get_player(e)
  player_table.gui.settings.logistics = e.element.state
  search_textfield_text_changed{tick=game.tick, player_index=e.player_index, element=player_table.gui.elems.search_textfield}
end

local function crafting_checkbox_state_changed(e)
  local player, player_table = util.get_player(e)
  player_table.gui.settings.crafting = e.element.state
  search_textfield_text_changed{tick=game.tick, player_index=e.player_index, element=player_table.gui.elems.search_textfield}
end

local function input_nav(e)
  util.log(e)
end

local handlers = {
  search_textfield_text_changed = search_textfield_text_changed,
  inventory_checkbox_state_changed = inventory_checkbox_state_changed,
  logistics_checkbox_state_changed = logistics_checkbox_state_changed,
  crafting_checkbox_state_changed = crafting_checkbox_state_changed,
  input_nav = input_nav
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- ----------------------------------------
-- GUI MANAGEMENT

function gui.create(parent, player, settings)
  local window = parent.add{type='frame', name='qis_window', style='dialog_frame', direction='vertical'}
  local search_textfield = window.add{type='textfield', name='qis_search_textfield', style='qis_search_textfield', lose_focus_on_confirm=true,
                                      clear_and_focus_on_right_click=true, text='Search...'}
  search_textfield.select_all()
  search_textfield.focus()
  event.on_gui_text_changed(search_textfield_text_changed, {name='search_textfield_text_changed', player_index=player.index, gui_filters=search_textfield})
  event.on_gui_confirmed(search_textfield_confirmed, {name='search_textfield_confirmed', player_index=player.index, gui_filters=search_textfield})
  local content_pane = window.add{type='frame', name='qis_content_pane', style='inside_deep_frame', direction='vertical'}
  local toolbar = content_pane.add{type='frame', name='qis_toolbar_frame', style='qis_toolbar'}
  local inventory_checkbox = toolbar.add{type='checkbox', name='qis_toolbar_inventory_checkbox', style='qis_inventory_checkbox',
                                         caption={'gui-qis.checkbox-inventory-label'}, state=settings.inventory}
  event.on_gui_checked_state_changed(inventory_checkbox_state_changed, {name='inventory_checkbox_state_changed', player_index=player.index,
                                     gui_filters=inventory_checkbox})
  local logistics_checkbox = toolbar.add{type='checkbox', name='qis_toolbar_logistics_checkbox', style='qis_logistics_checkbox',
                                         caption={'gui-qis.checkbox-logistics-label'}, state=settings.logistics}
  event.on_gui_checked_state_changed(logistics_checkbox_state_changed, {name='logistics_checkbox_state_changed', player_index=player.index,
                                     gui_filters=logistics_checkbox})
  local crafting_checkbox = toolbar.add{type='checkbox', name='qis_toolbar_crafting_checkbox', style='qis_crafting_checkbox',
                                         caption={'gui-qis.checkbox-crafting-label'}, state=settings.crafting}
  event.on_gui_checked_state_changed(crafting_checkbox_state_changed, {name='crafting_checkbox_state_changed', player_index=player.index,
                                     gui_filters=crafting_checkbox})
  util.gui.add_pusher(toolbar, 'qis_toolbar_pusher')
  local results_scroll = content_pane.add{type='scroll-pane', name='qis_results_scroll_pane', style='results_scroll_pane', vertical_scroll_policy='always'}
  local results_table = results_scroll.add{type='table', name='qis_results_table', style='results_slot_table', column_count=6}
  event.register({'qis-nav-up', 'qis-nav-left', 'qis-nav-down', 'qis-nav-right'}, input_nav, {name='input_nav', player_index=player.index})
  return {window=window, search_textfield=search_textfield, results_table=results_table}
end

function gui.destroy(window, player_index)
  -- deregister all GUI events if needed
  local con_registry = global.conditional_event_registry
  for cn,h in pairs(handlers) do
    event.deregister(con_registry[cn].id, h, {name=cn, player_index=player_index})
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
    dictionary[data.name] = {type=data.type, name=string.lower(e.result)}
  else
    util.log('\''..string.gsub(e.localised_string[1], '(.+)%.', '')..'\' was not translated, and will not be searchable.')
    player_table.finished_size_offset = player_table.finished_size_offset + 1
  end
  if table_size(prototype_dictionary) - table_size(dictionary) - player_table.finished_size_offset == 0 then
    player_table.prototype_dictionary = nil
    player_table.finished_size_offset = nil
    player_table.flags.building_dictionary = false
    event.raise(translation_finished_event, {player_index=e.player_index})
  end
end)

event.register(translation_started_event, function(e)
  util.log('translation started!')
end)

event.register(translation_finished_event, function(e)
  util.log('translation finished!')
end)

event.register('qis-search', function(e)
  local player, player_table = util.get_player(e)
  if not player_table.gui.elems then
    player_table.gui.elems = gui.create(mod_gui.get_frame_flow(player), player, player_table.gui.settings)
    player.opened = player_table.gui.elems.window
  else
    gui.destroy(player_table.gui.elems.window, player.index)
    player_table.gui.elems = nil
  end
end)

event.register(defines.events.on_gui_closed, function(e)
  if e.gui_type == 16 and e.element.name == 'qis_window' then
    gui.destroy(e.element, e.player_index)
    util.player_table(e).gui.elems = nil
  end
end)