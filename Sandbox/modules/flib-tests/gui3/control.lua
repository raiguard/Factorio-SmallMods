local event = require("__flib__.event")
local gui = require("__flib__.gui3")

local counter = require("modules.flib-tests.gui3.counter")

event.on_init(function()
  gui.init()
  global.players = {}
end)

event.on_load(function()
  gui.load()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local Counter = counter:new(player.gui.screen)
  global.players[e.player_index] = Counter
end)

event.on_player_removed(function(e)
  local Counter = global.players[e.player_index]
  if Counter then
    Counter:destroy()
    global.players[e.player_index] = nil
  end
end)

gui.register_handlers()
