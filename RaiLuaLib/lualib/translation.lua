-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB TRANSLATION LIBRARY
-- Requests and organizes translations for localised strings

-- DOCUMENTATION: https://github.com/raiguard/Factorio-SmallMods/wiki/Translation-Library-Documentation

--[[
  player.request_translation(localised_string)
  -> event.on_string_translated(e)
]]

local string_gsub = string.gsub
local string_lower = string.lower

local translation = {}
local registered_mod_count = 1
translation.start_event = script.generate_event_name()
translation.finish_event = script.generate_event_name()

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
  if __translation and __translation.event_registered then -- if we should be doing something
    local iterations = 100 / __translation.dictionary_count / registered_mod_count
    for pi,pt in pairs(__translation.players) do -- for each player that is doing a translation
      for name,t in pairs(pt) do -- for each dictionary that they're translating
        local next_index = t.next_index
        local request_translation = t.request_translation
        local strings = t.strings
        local strings_len = t.strings_len
        for i=next_index,next_index+iterations do
          if i <= strings_len then
            request_translation(strings[i])
          end
        end
        t.next_index = next_index + iterations
      end
    end
  end
end

function translation.start(player, dictionary_name, data, strings)
  if not global.__translation then
    global.__translation = {
      event_registered = false,
      dictionary_count = 0,
      players = {},
      player_count = 0
    }
  end
  local __translation = global.__translation
  if not __translation.players[player.index] then __translation.players[player.index] = {} end
  local player_translation = __translation.players[player.index]
  if player_translation[dictionary_name] then error('Already translating dictionary: '..dictionary_name) end
  player_translation[dictionary_name] = {
    -- tables
    data = data,
    strings = strings,
    -- iteration
    next_index = 1,
    player = player,
    request_translation = player.request_translation,
    strings_len = #strings,
    -- output
    result = {}
  }
  __translation.event_registered = true
  __translation.dictionary_count = __translation.dictionary_count + 1
end

function translation.on_string_translated_event(e)
  local profiler = game.create_profiler()
  local __translation = global.__translation
  local player_translation = __translation.players[e.player_index]
  local serialised = serialise_localised_string(e.localised_string)
  for name,t in pairs(player_translation) do
    local value = t.data[serialised]
    if value then
      t.result[e.result] = value
      t.data[serialised] = nil
      if table_size(t.data) == 0 then
        local result = t.result
        player_translation[name] = nil
        if table_size(player_translation) == 0 then
          __translation.players[e.player_index] = nil
          if table_size(__translation.players) == 0 then
            __translation.event_registered = false
          end
        end
        return result
      end
      return
    end
  end
end

translation.serialise_localised_string = serialise_localised_string
translation.on_tick_event = translate_batch

return translation