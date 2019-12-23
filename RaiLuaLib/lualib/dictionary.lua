-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALUB LOCALISED DICTIONARY
-- v1.0.0

-- DOCUMENTATION: https://github.com/raiguard/SmallFactorioMods/wiki/Localised-Dictionary-Documentation

-- DEPENDENCIES:
local event = require('lualib/event')

local dictionary = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- count of mods that are using this library
local registered_mods = 0

-- set up player's table in global
local function setup_player(player)
  global.dictionaries[player.index] = {
    __build = {}
  }
end

local function rebuild_all(e)
  local build_data = global.dictionaries.__build
  for _,p in pairs(game.players) do
    if p.connected then
      dictionary.player_setup_function(p, build_data)
    end
  end
  if e.name == defines.events.on_tick then
    event.deregister(defines.events.on_tick, rebuild_all)
  end
end

local function setup_remote()
  if not remote.interfaces['localised_dictionary'] then -- create the interface
    local functions = {
      build_start_event = function() return event.generate_id('build_start_event') end,
      build_finish_event = function() return event.generate_id('build_finish_event') end,
      rebuild_all_event = function() return event.generate_id('rebuild_all_event') end,
      register_mod = function() registered_mods = registered_mods + 1 end
    }
    remote.add_interface('localised_dictionary', functions)
    commands.add_command(
      'rebuild-localised-dictionaries',
      {'command-help.rebuild-localised-dictionaries'},
      function(e)
        event.raise(dictionary.rebuild_all_event, {})
      end
    )
  end
  dictionary.rebuild_all_event = remote.call('localised_dictionary', 'rebuild_all_event')
  event.register(dictionary.rebuild_all_event, rebuild_all)
  remote.call('localised_dictionary', 'register_mod')
end

local function request_translations_batch()
  for pi,t in pairs(global.dictionaries) do -- for each player
    if type(pi) == 'number' then
      for _,building in ipairs(t.__build) do -- for each dictionary that is being translated
        local next_index = building.next_index
        local iteration_dictionary = building.iteration_dictionary
        local request_translation = building.request_translation
        for i=1,10 do
          request_translation(iteration_dictionary[next_index])
          next_index = next_index + 1
        end
        building.next_index = next_index
      end
    end
  end
end

-- -----------------------------------------------------------------------------
-- LIBRARY

dictionary.player_setup_function = function(player, build_data) error('Did not define dictionary.player_setup_function') end
dictionary.build_setup_function = function() log('Did not define a custom dictionary.build_setup_function') end

dictionary.build_start_event = event.generate_id('dictionary_build_start_event')
dictionary.build_finish_event = event.generate_id('dictionary_build_finish_event')

function dictionary.get(player, dict_name)
  return global.dictionaries[player.index][dict_name]
end

-- build the dictionary
function dictionary.build(player, dict_name, prototype_dictionary, iteration_dictionary, translation_function, conflict_function)
  event.raise(dictionary.build_start_event, {player_index=player.index, dict_name=dict_name})
  global.dictionaries[player.index][dict_name] = nil
  table.insert(global.dictionaries[player.index].__build, {
    dict_name = dict_name,
    dictionary = {},
    prototype_dictionary = prototype_dictionary,
    iteration_dictionary = iteration_dictionary,
    translation_function = translation_function,
    conflict_function = conflict_function,
    next_index = 1,
    player = player,
    request_translation = player.request_translation
  })
  -- request translations
  if not event.is_registered('dictionary_request_translations_batch', player.index) then
    event.on_nth_tick(5, request_translations_batch, {name='dictionary_request_translations_batch', player_index=player.index})
  end
end

-- converts a localised string into a format readable by the API
function dictionary.serialise_localised_string(t)
  local output = '{'
  for _,v in pairs(t) do
    if type(v) == 'table' then
      output = output..dictionary.serialise_localised_string(v)
    else
      output = output..'\''..v..'\', '
    end
  end
  output = output:gsub(', $', '')..'}'
  return output
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- when a string gets translated
event.on_string_translated(function(e)
  local player_table = global.dictionaries[e.player_index]
  for i,t in ipairs(player_table.__build) do
    local prototype_dictionary = t.prototype_dictionary
    local dict = t.dictionary
    local serialised_key = dictionary.serialise_localised_string(e.localised_string)
    local dict_match = prototype_dictionary[serialised_key]
    if dict_match then -- if this translation belongs to this table
      if e.translated then
        local key, value = t.translation_function(e, dict_match)
        if dict[key] then
          dict[key] = t.conflict_function(e, dict_match, dict[key])
        else
          dict[key] = value
        end
      else
        log('\''..string.gsub(e.localised_string[1], '(.+)%.', '')..'\' was not translated, and will not be included in the localised dictionary.')
      end
      prototype_dictionary[serialised_key] = nil
      if table_size(prototype_dictionary) == 0 then
        player_table[t.dict_name] = table.deepcopy(t.dictionary)
        table.remove(player_table.__build, i)
        if #player_table.__build == 0 then
          event.deregister(-5, request_translations_batch, {name='dictionary_request_translations_batch', player_index=e.player_index})
        end
        event.raise(dictionary.build_finish_event, {player_index=e.player_index, dict_name=t.dict_name})
      end
      break
    end
  end
end)

event.on_init(function()
  global.dictionaries = {}
  local players = game.players
  -- set up player global tables
  for _,p in pairs(players) do
    setup_player(p)
  end
  if #game.players > 0 then
    event.on_tick(rebuild_all)
  end
  setup_remote()
  global.dictionaries.__build = dictionary.build_setup_function(dictionary.serialise_localised_string)
end)

event.on_load(function()
  setup_remote()
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.on_player_joined_game(function(e)
  dictionary.player_setup_function(game.get_player(e.player_index), global.dictionaries.__build)
end)

event.on_configuration_changed(function()
  global.dictionaries.__build = dictionary.build_setup_function(dictionary.serialise_localised_string)
  local build_data = global.dictionaries.__build
  for _,p in pairs(game.players) do
    if p.connected then
      dictionary.player_setup_function(p, build_data)
    end
  end
end)

-- -----------------------------------------------------------------------------

return dictionary