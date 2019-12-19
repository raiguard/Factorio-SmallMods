-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALUB LOCALISED DICTIONARY
-- v1.0.0

-- DOCUMENTATION: https://github.com/raiguard/SmallFactorioMods/wiki/Localised-Dictionary-Documentation

-- DEPENDENCIES:
local event = require('lualib/event')

-- -----------------------------------------------------------------------------

-- library
local dictionary = {}
dictionary.on_init = function() end -- blank function
dictionary.build_start_event = event.generate_id('dictionary_build_start')
dictionary.build_finish_event = event.generate_id('dictionary_build_finish')
dictionary.setup_function = function(player)
  error('Must define a setup function to use the localised dictionary! See the documentation for more info.')
end
dictionary.get_data_function = function(e, data)
  error('Must define an insert data function to use the localised dictionary! See the documentation for more info.')
end
dictionary.get = function(obj)
  if type(obj) == 'number' then return global.dictionary[obj] -- gave the player_index itself
  elseif obj.__self then return global.dictionary[obj.index] -- gave a player object
  else return global.dictionary[obj.player_index] end -- gave the event table
end
dictionary.search = function(player, search_func)
  local results = {}
  for k,v in pairs(dictionary.get(player)) do
    local value,key = search_func(k,v)
    if value then
      if key then
        results[key] = value
      else
        table.insert(results, value)
      end
    end
  end
  return results
end

local function setup_player(player)
  global.dictionary[player.index] = {}
end

local function build_dictionary(player)
  event.raise(dictionary.build_start_event, {player_index=player.index})
  local prototype_dictionary = dictionary.setup_function(player)
  global.dictionary[player.index] = {
    building = true,
    dictionary = {},
    finished_size_offset = 0,
    prototype_dictionary = prototype_dictionary
  }
  -- request translations
  for name,_ in pairs(prototype_dictionary) do
    player.request_translation{name}
  end
end

-- when a string gets translated
event.register(defines.events.on_string_translated, function(e)
  local player_table = global.dictionary[e.player_index]
  local prototype_dictionary = player_table.prototype_dictionary
  if player_table.building and table_size(player_table) == 4 then
    local dict = player_table.dictionary
    if e.translated then
      local key, value = dictionary.get_data_function(e, player_table.prototype_dictionary[e.localised_string[1]])
      dict[key] = value
    else
      log('\''..string.gsub(e.localised_string[1], '(.+)%.', '')..'\' was not translated, and will not be searchable.')
      player_table.finished_size_offset = player_table.finished_size_offset + 1
    end
    if table_size(prototype_dictionary) - table_size(dict) - player_table.finished_size_offset == 0 then
      global.dictionary[e.player_index] = player_table.dictionary
      event.raise(dictionary.build_finish_event, {player_index=e.player_index})
    end
  end
end)

event.on_init(function()
  local function on_tick(e)
    for i,p in pairs(game.players) do
      build_dictionary(p)
    end
    event.deregister(defines.events.on_tick, on_tick)
  end
  global.dictionary = {}
  -- set up player globals
  for i,p in pairs(game.players) do
    setup_player(p)
  end
  if #game.players > 0 then
    -- build dictionaries for all players on the first tick
    event.on_tick(on_tick)
  end
end)

event.on_player_created(function(e)
  setup_player(game.players[e.player_index])
end)

-- when a player joins a game, rebuild their dictionary
event.on_player_joined_game(function(e)
  build_dictionary(game.players[e.player_index])
end)

commands.add_command('rebuild-localised-dictionary', nil, function(e) build_dictionary(game.players[e.player_index]) end)

return dictionary