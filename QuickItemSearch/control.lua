-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH CONTROL SCRIPTING

local event = require('lualib/event')
local util = require('lualib/util')

local mod_gui = require('mod-gui')
local dictionary_generated_event = event.generate_id('dictionary_generated')

-- -----------------------------------------------------------------------------
-- UTILITIES

local function search_textfield_text_changed(e)
  local player = util.get_player(e)
end

-- setup player global table and GUI
local function setup_player(player)
  local data = {
    dictionary = {},
    flags = {
      building_dictionary = false
    }
  }
  event.gui.on_text_changed(
    mod_gui.get_frame_flow(player).add{type='textfield', name='qis_search_textfield', lose_focus_on_confirm=true},
    search_textfield_text_changed, 'search_textfield_text_changed', player.index
  )
  global.players[player.index] = data
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

event.register(defines.events.on_string_translated, function(e)
  local player_table = util.player_table(e)
  if e.translated then
    player_table.dictionary[player_table.prototype_dictionary[e.localised_string[1]]] = e.result
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