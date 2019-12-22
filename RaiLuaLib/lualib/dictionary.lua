-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALUB LOCALISED DICTIONARY
-- v1.0.0

-- DOCUMENTATION: https://github.com/raiguard/SmallFactorioMods/wiki/Localised-Dictionary-Documentation

-- DEPENDENCIES:
local event = require('lualib/event')

-- -----------------------------------------------------------------------------

-- library
local dictionary = {}
dictionary.build_start_event = event.generate_id('dictionary_build_start')
dictionary.build_finish_event = event.generate_id('dictionary_build_finish')
dictionary.player_setup_function = function(player) error('Did not define dictionary.player_setup_function') end

function dictionary.get(player, dict_name)
  return global.dictionaries[player.index][dict_name]
end

-- build the dictionary
function dictionary.build(player, dict_name, prototype_dictionary, translation_function)
  event.raise(dictionary.build_start_event, {player_index=player.index, dict_name=dict_name})
  table.insert(global.dictionaries[player.index].__build, {
    dict_name = dict_name,
    dictionary = {},
    finished_size_offset = 0,
    prototype_dictionary = prototype_dictionary,
    translation_function = translation_function
  })
  -- request translations
  for name,_ in pairs(prototype_dictionary) do
    player.request_translation{name}
  end
end

-- when a string gets translated
event.on_string_translated(function(e)
  local player_table = global.dictionaries[e.player_index]
  for i,t in ipairs(player_table.__build) do
    local prototype_dictionary = t.prototype_dictionary
    local dict = t.dictionary
    local dict_match = prototype_dictionary[e.localised_string[1]]
    if dict_match then -- if this translation belongs to this table
      if e.translated then
        local key, value = t.translation_function(e, dict_match)
        dict[key] = value
      else
        log('\''..string.gsub(e.localised_string[1], '(.+)%.', '')..'\' was not translated, and will not be included in the localised dictionary.')
        t.finished_size_offset = t.finished_size_offset + 1
      end
      if table_size(prototype_dictionary) - table_size(dict) - t.finished_size_offset == 0 then
        player_table[t.dict_name] = table.deepcopy(t.dictionary)
        table.remove(player_table.__build, i)
        event.raise(dictionary.build_finish_event, {player_index=e.player_index, dict_name=t.dict_name})
      end
      break
    end
  end
end)

-- set up player's table in global
local function setup_player(player)
  global.dictionaries[player.index] = {
    __build = {}
  }
end

event.on_init(function()
  local function first_tick(e)
    for _,p in pairs(game.players) do
      if p.connected then
        dictionary.player_setup_function(p)
      end
    end
    event.deregister(defines.events.on_tick, first_tick)
  end
  global.dictionaries = {}
  local players = game.players
  -- set up player global tables
  for _,p in pairs(players) do
    setup_player(p)
  end
  if #game.players > 0 then
    event.on_tick(first_tick)
  end
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.on_player_joined_game(function(e)
  dictionary.player_setup_function(game.get_player(e.player_index))
end)

event.on_configuration_changed(function()
  for _,p in pairs(game.players) do
    if p.connected then
      dictionary.player_setup_function(p)
    end
  end
end)

return dictionary