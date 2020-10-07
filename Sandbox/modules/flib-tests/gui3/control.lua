local event = require("__flib__.event")
local gui = require("__flib__.gui3")

local counter_gui = require("modules.flib-tests.gui3.counter")
local todo_gui = require("modules.flib-tests.gui3.todo")

event.on_init(function()
  gui.init()
  global.players = {}
end)

event.on_load(function()
  gui.load()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local Counter = counter_gui:new(player.gui.screen)
  local Todo = todo_gui:new(player.gui.screen)
  global.players[e.player_index] = {
    counter = Counter,
    todo = Todo
  }
end)

event.on_player_removed(function(e)
  local player_table = global.players[e.player_index]
  if player_table then
    player_table.counter:destroy()
    player_table.todo:destroy()
    global.players[e.player_index] = nil
  end
end)

gui.register_handlers()
