-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

local event = require('lualib/event')
local util = require('lualib/util')

local mod_gui = require('mod-gui')
local dictionary_generated_event = event.generate_id('dictionary_generated')

local gui = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

local function search_textfield_text_changed(e)
  local player, player_table = util.get_player(e)
  if not player_table.flags.building_dictionary then
    local results_flow = player_table.gui.results_flow
    results_flow.clear()
    local i = 0
    if e.element.text == '' then return end
    for internal,localized in pairs(player_table.dictionary) do
      if localized:match(e.element.text) then
        i = i + 1
        results_flow.add{type='label', name='qis_result_'..i, caption=localized}
      end
    end
  end
end

-- setup player global table and GUI
local function setup_player(player)
  local data = {
    dictionary = {},
    flags = {
      building_dictionary = false
    }
  }
  global.players[player.index] = data
end

-- -----------------------------------------------------------------------------
-- GUI

-- ----------------------------------------
-- GUI HANDLERS

local handlers = {

}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- ----------------------------------------
-- GUI MANAGEMENT

function gui.create(parent, player)
  local window = parent.add{type='frame', name='qis_window', style='dialog_frame', direction='vertical'}
  local search_flow = window.add{type='flow', name='qis_search_flow', direction='horizontal'}
  local search_textfield = search_flow.add{type='textfield', name='qis_search_textfield'}
  util.gui.add_pusher(search_flow, 'qis_search_pusher')
  local close_button = search_flow.add{type='sprite-button', name='qis_close_button', style='qis_close_button', sprite='utility/close_white',
                                       hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
  local results_scroll = window.add{type='scroll-pane', name='qis_results_scroll_pane', style='results_scroll_pane', vertical_scroll_policy='always'}
  local results_table = results_scroll.add{type='table', name='qis_results_table', style='results_slot_table', column_count=6}
  search_textfield.focus()
  return {search_textfield=search_textfield, close_button=close_button}
end

function gui.destroy(window, player_index)
  -- deregister all GUI events if needed
  local con_registry = global.conditional_event_registry
  for cn,h in pairs(handlers) do
    event.gui.deregister(con_registry[cn].id, h, cn, player_index)
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

-- when a player is created
event.register(defines.events.on_player_created, function(e)
  local player = game.players[e.player_index]
  setup_player(player)
end)

-- when a player joins a game
event.register(defines.events.on_player_joined_game, function(e)
  local player, player_table = util.get_player(e)
  player_table.flags.building_dictionary = true
  player_table.prototype_dictionary = {}
  player_table.finished_size_offset = 0
  for name,prototype in pairs(game.item_prototypes) do
    player.request_translation(prototype.localised_name)
    player_table.prototype_dictionary[prototype.localised_name[1]] = prototype.name
  end
end)

-- when a string gets translated
event.register(defines.events.on_string_translated, function(e)
  local player_table = util.player_table(e)
  if e.translated and player_table.flags.building_dictionary then
    player_table.dictionary[player_table.prototype_dictionary[e.localised_string[1]]] = string.lower(e.result)
  else
    util.log('Item \''..string.gsub(e.localised_string[1], '(.+)%.', '')..'\' was not translated, and will not be searchable.')
    player_table.finished_size_offset = player_table.finished_size_offset + 1
  end
  if table_size(player_table.prototype_dictionary) - table_size(player_table.dictionary) - player_table.finished_size_offset == 0 then
    player_table.prototype_dictionary = nil
    player_table.finished_size_offset = nil
    player_table.flags.building_dictionary = false
    event.raise(dictionary_generated_event, {})
  end
end)

event.register(dictionary_generated_event, function(e)
  
end)

event.register('qis-search', function(e)
  local player, player_table = util.get_player(e)
  if not player_table.gui then
    local elems = gui.create(mod_gui.get_frame_flow(player))
    player_table.gui = {elems=elems}
  else
    gui.destroy(player_table.gui.elems.window)
  end
end)