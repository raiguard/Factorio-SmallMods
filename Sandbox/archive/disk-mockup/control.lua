local gui = require("__RaiLuaLib__.lualib.gui")
local mod_gui = require("mod-gui")

script.on_event(defines.events.on_player_created, function(e)
  gui.build(mod_gui.get_frame_flow(game.get_player(e.player_index)), {
    {type="frame", }
  })
end)