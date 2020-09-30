local event = require("__flib__.event")
local gui = require("__flib__.gui2")

local counter = require("flib-tests.gui2.counter")

event.on_init(function()
  gui.init()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  counter:create(player.gui.screen)
end)

gui.register_handlers()