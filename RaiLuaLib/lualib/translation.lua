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

local registered_mod_count = 1

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

-- translate 100 entries per tick
local function translate_batch(e)
  local __translation = global.__translation
  local iterations = math_floor(100 / __translation.dictionary_count / registered_mod_count)
  for _,pt in pairs(__translation.players) do -- for each player that is doing a translation
    for _,t in pairs(pt) do -- for each dictionary that they're translating
      local next_index = t.next_index
      local request_translation = t.request_translation
      local strings = t.strings
      local strings_len = t.strings_len
      for i=next_index,next_index+iterations do
        if i <= strings_len then
          if strings[i] == nil then
            local breakpoint
          end
          request_translation(strings[i])
        end
      end
      t.next_index = next_index + iterations
    end
  end
end

local function parse_translation_result(e)
  local __translation = global.__translation
  local player_translation = __translation.players[e.player_index]
  local serialised = serialise_localised_string(e.localised_string)
  for name,t in pairs(player_translation) do
    local value = t.data[serialised]
    if value then
      t.result[e.result] = value
      t.data[serialised] = nil
      if table_size(t.data) == 0 then -- this dictionary has completed translation
        local result = t.result
        player_translation[name] = nil
        __translation.dictionary_count = __translation.dictionary_count - 1
        if table_size(player_translation) == 0 then
          __translation.players[e.player_index] = nil
          if table_size(__translation.players) == 0 then
            event.deregister(defines.events.on_tick, translate_batch, {name='translation_translate_batch'})
            event.deregister(defines.events.on_string_translated, parse_translation_result, {name='translation_parse_result'})
            global.__translation = nil
          end
        end
        event.raise(translation.finish_event, {player_index=e.player_index, dictionary_name=name, dictionary=t.result})
      end
      return
    end
  end
end

translation.serialise_localised_string = serialise_localised_string

function translation.start(player, dictionary_name, data, strings)
  if not global.__translation then
    global.__translation = {
      dictionary_count = 0,
      players = {}
    }
  end
  local __translation = global.__translation
  if not __translation.players[player.index] then __translation.players[player.index] = {} end
  local player_translation = __translation.players[player.index]
  if player_translation[dictionary_name] then error('Already translating dictionary: '..dictionary_name) end
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
  __translation.dictionary_count = __translation.dictionary_count + 1
  if not event.is_registered('translation_translate_batch') then
    event.on_tick(translate_batch, {name='translation_translate_batch'})
    event.on_string_translated(parse_translation_result, {name='translation_parse_result'})
  end
  event.raise(translation.start_event, {player_index=player.index, dictionary_name=dictionary_name})
end



return translation