-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRANSLATION LIBRARY CONTROL TESTS

local event = require('lualib/event')
local translation = require('lualib/translation')

local serialise_localised_string = translation.serialise_localised_string

local function build_data()
  local data = {}
  local strings = {}
  for name,prototype in pairs(game.recipe_prototypes) do
    data[serialise_localised_string(prototype.localised_name)] = name
    table.insert(strings, prototype.localised_name)
  end
  global.data = data
  global.strings = strings
end

event.on_init(function()
  build_data()
end)

event.on_configuration_changed(function()
  build_data()
end)

event.on_string_translated(translation.on_string_translated_event)

event.on_tick(function(e)
  if e.tick == 1 then
    translation.start(game.get_player(1), 'recipe', global.data, global.strings)
  end
  translation.on_tick_event(e)
end)