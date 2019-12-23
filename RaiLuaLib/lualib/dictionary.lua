-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALUB LOCALISED DICTIONARY
-- v1.0.0

-- DOCUMENTATION: https://github.com/raiguard/SmallFactorioMods/wiki/Localised-Dictionary-Documentation

-- DEPENDENCIES:
local event = require('lualib/event')

local dictionary = {}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- set up player's table in global
local function setup_player(player)
  global.dictionaries[player.index] = {
    __build = {}
  }
end

local function rebuild_all(e)
  for _,p in pairs(game.players) do
    if p.connected then
      dictionary.player_setup_function(p)
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
      rebuild_all_event = function() return event.generate_id('rebuild_all_event') end
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
  dictionary.build_start_event = remote.call('localised_dictionary', 'build_start_event')
  dictionary.build_finish_event = remote.call('localised_dictionary', 'build_finish_event')
  dictionary.rebuild_all_event = remote.call('localised_dictionary', 'rebuild_all_event')
  event.register(dictionary.rebuild_all_event, rebuild_all)
end

-- -----------------------------------------------------------------------------
-- LIBRARY

dictionary.player_setup_function = function(player, build_data) error('Did not define dictionary.player_setup_function') end
dictionary.build_setup_function = function() log('Did not define a custom dictionary.build_setup_function') end

function dictionary.get(player, dict_name)
  return global.dictionaries[player.index][dict_name]
end

-- build the dictionary
function dictionary.build(player, dict_name, prototype_dictionary, translation_function, conflict_function)
  event.raise(dictionary.build_start_event, {player_index=player.index, dict_name=dict_name})
  global.dictionaries[player.index][dict_name] = nil
  table.insert(global.dictionaries[player.index].__build, {
    dict_name = dict_name,
    dictionary = {},
    finished_size_offset = 0,
    prototype_dictionary = prototype_dictionary,
    translation_function = translation_function,
    conflict_function = conflict_function
  })
  -- request translations
  -- TODO: SPREAD THIS OUT OVER MULTIPLE TICKS SO PLAYERS DON'T GET A PING OF DEATH WHEN JOINING SERVERS
  for _,v in pairs(prototype_dictionary) do
    player.request_translation(v.localised_name)
  end
end

-- converts a localised string into a format readable by the API
function dictionary.serialise_localised_string(t)
  sep = sep or '@@'
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
    local dict_match = prototype_dictionary[dictionary.serialise_localised_string(e.localised_string)]
    if dict_match then -- if this translation belongs to this table
      if e.translated then
        local key, value = t.translation_function(e, dict_match)
        if dict[key] then
          local new_key, add_offset = t.conflict_function(e, dict_match, dict[key])
          dict[key] = new_key
          if add_offset then
            t.finished_size_offset = t.finished_size_offset + 1
          end    
        else
          dict[key] = value
        end
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