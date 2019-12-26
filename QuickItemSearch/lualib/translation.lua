-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB TRANSLATION LIBRARY
-- Requests and organizes translations for localised strings

-- DOCUMENTATION: https://github.com/raiguard/Factorio-SmallMods/wiki/Translation-Library-Documentation

-- dependencies
local event = require('lualib/event')
local util = require('__core__/lualib/util')

-- locals
local string_gsub = string.gsub
local math_floor = math.floor

-- -----------------------------------------------------------------------------

local translation = {}
translation.start_event = event.generate_id('translation_start')
translation.finish_event = event.generate_id('translation_finish')

-- converts a localised string into a format readable by the API
-- basically just spits out the table in string form
local function serialise_localised_string(t)
  local output = '{'
  for _,v in pairs(t) do
    if type(v) == 'table' then
      output = output..serialise_localised_string(v)
    else
      output = output..'\''..v..'\', '
    end
  end
  output = string_gsub(output, ', $', '')..'}'
  return output
end

-- translate 80 entries per tick
local function translate_batch()
  local __translation = global.__translation
  local iterations = math_floor(80 / __translation.dictionary_count)
  if iterations < 1 then iterations = 1 end
  for _,pt in pairs(__translation.players) do -- for each player that is doing a translation
    for _,t in pairs(pt) do -- for each dictionary that they're translating
      local next_index = t.next_index
      local request_translation = t.request_translation
      local strings = t.strings
      local strings_len = t.strings_len
      for i=next_index,next_index+iterations do
        if i > strings_len then
          break
        end
        request_translation(strings[i])
      end
      t.next_index = next_index + iterations
    end
  end
end

-- sorts a translated string into its appropriate dictionary
local function sort_translated_string(e)
  local __translation = global.__translation
  local player_translation = __translation.players[e.player_index]
  local serialised = serialise_localised_string(e.localised_string)
  for name,t in pairs(player_translation) do
    local value = t.data[serialised]
    if value then
      if e.translated then
        local result = t.result[e.result]
        if result then
          result[#result+1] = value
        else
          t.result[e.result] = {value}
        end
      else
        log('Key: '..serialised..' for dictionary: '..name..' was not successfully translated, and will not be included in the output table')
      end
      t.data[serialised] = nil
      if table_size(t.data) == 0 then -- this dictionary has completed translation
        player_translation[name] = nil
        if table_size(player_translation) == 0 then -- remove player from translating table if they're done
          __translation.players[e.player_index] = nil
        end
        event.raise(translation.update_dictionary_count_event, {delta=-1})
        event.raise(translation.finish_event, {player_index=e.player_index, dictionary_name=name, dictionary=t.result})
      end
      return
    end
  end
end

translation.serialise_localised_string = serialise_localised_string

-- begin translating strings
function translation.start(player, dictionary_name, data, strings, ignore_error)
  local __translation = global.__translation
  if not __translation.players[player.index] then __translation.players[player.index] = {} end
  local player_translation = __translation.players[player.index]
  if player_translation[dictionary_name] then
    if ignore_error then return end
    error('Already translating dictionary: '..dictionary_name)
  end
  player_translation[dictionary_name] = {
    -- tables
    data = table.deepcopy(data), -- this table gets destroyed as it is translated, so deepcopy it
    strings = strings,
    -- iteration
    next_index = 1,
    player = player,
    request_translation = player.request_translation,
    strings_len = #strings,
    -- output
    result = {}
  }
  event.raise(translation.update_dictionary_count_event, {delta=1})
  event.raise(translation.start_event, {player_index=player.index, dictionary_name=dictionary_name})
end

-- REMOTE INTERFACE: CROSS-MOD SYNCRONISATION

local function setup_remote()
  if not remote.interfaces['railualib_translation'] then -- create the interface
    local functions = {
      retranslate_all_event = function() return event.generate_id('retranslate_all_event') end,
      update_dictionary_count_event = function() return event.generate_id('update_dictionary_count_event') end
    }
    remote.add_interface('railualib_translation', functions)
    commands.add_command(
      'retranslate-all-dictionaries',
      {'command-help.retranslate-all-dictionaries'},
      function(e)
        event.raise(translation.retranslate_all_event, {})
      end
    )
  end
  translation.retranslate_all_event = remote.call('railualib_translation', 'retranslate_all_event')
  translation.update_dictionary_count_event = remote.call('railualib_translation', 'update_dictionary_count_event')
  event.register(translation.update_dictionary_count_event, function(e)
    local __translation = global.__translation
    if __translation.dictionary_count == 0 then -- register events if we're starting
      event.on_tick(translate_batch, {name='translation_translate_batch'})
      event.on_string_translated(sort_translated_string, {name='translation_sort_result'})
    end
    __translation.dictionary_count = __translation.dictionary_count + e.delta
    if __translation.dictionary_count == 0 then -- deregister events if we're all done
      event.deregister(defines.events.on_tick, translate_batch, {name='translation_translate_batch'})
      event.deregister(defines.events.on_string_translated, sort_translated_string, {name='translation_sort_result'})
    end
  end)
end

event.on_init(function()
  global.__translation = {
    dictionary_count = 0,
    players = {}
  }
  setup_remote()
end)

event.on_load(function()
  setup_remote()
end)

return translation