-- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

local mod_gui = require('mod-gui')

script.on_event(defines.events.on_player_created, function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{type='button', name='test_button', caption='Exception'}
end)

local function dummy_handler(e)
  game.print(serpent.block(e))
end

script.on_event(defines.events.on_gui_click, function(e)
  script.on_event('nonexistent-event', dummy_handler)
end)