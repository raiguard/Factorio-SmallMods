-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRANSLATION LIBRARY CONTROL TESTS

local event = require('lualib/event')
local translation = require('lualib/translation')
local util = require('lualib/util')

local serialise_localised_string = translation.serialise_localised_string

-- build LOTS of data to really stress the translation engine
local function build_data()
  local build = {}
  local function generic_setup(key)
    local data = {}
    local strings = {}
    local strings_len = 0
    for name,prototype in pairs(game[key..'_prototypes']) do
      data[serialise_localised_string(prototype.localised_name)] = name
      strings_len = strings_len + 1
      strings[strings_len] = prototype.localised_name
    end
    return {data=data, strings=strings}
  end
  build.achievement = generic_setup('achievement')
  build.entity = generic_setup('entity')
  build.equipment = generic_setup('equipment')
  build.fluid = generic_setup('fluid')
  build.item = generic_setup('item')
  build.recipe = generic_setup('recipe')
  build.technology = generic_setup('technology')
  build.tile = generic_setup('tile')
  global.__build = build
end

local function translate_whole(player)
  for name,t in pairs(global.__build) do
    translation.start(player, name, t.data, t.strings)
  end
end

local function translate_for_all_players()
  global.results = {}
  for _,player in ipairs(game.connected_players) do
    translate_whole(player)
  end
end

event.on_init(function()
  build_data()
  global.results = {}
  translate_for_all_players()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_configuration_changed(function()
  build_data()
  translate_for_all_players()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_player_joined_game(function(e)
  translate_whole(game.get_player(e.player_index))
end)

event.register(translation.finish_event, function(e)
  game.print('finished translation of dictionary: '..e.dictionary_name)
  global.results[e.dictionary_name] = e.dictionary
end)