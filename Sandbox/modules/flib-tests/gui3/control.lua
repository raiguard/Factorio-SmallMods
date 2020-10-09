local event = require("__flib__.event")
local gui = require("__flib__.gui3")

local counter_gui = require("modules.flib-tests.gui3.Counter")
local tabs_gui = require("modules.flib-tests.gui3.Tabs")
local todo_gui = require("modules.flib-tests.gui3.Todo")

event.on_init(function()
  gui.init()
  global.players = {}
end)

event.on_load(function()
  gui.load()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  global.players[e.player_index] = {
    Counter = gui.new(counter_gui, player.gui.screen),
    Tabs = gui.new(tabs_gui, player.gui.screen),
    Todo = gui.new(todo_gui, player.gui.screen)
  }
end)

event.on_player_removed(function(e)
  local player_table = global.players[e.player_index]
  if player_table then
    player_table.Counter:destroy()
    player_table.Todo:destroy()
    global.players[e.player_index] = nil
  end
end)

gui.register_handlers()