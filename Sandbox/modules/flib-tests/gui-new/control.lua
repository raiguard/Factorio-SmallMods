local event = require("__flib__.event")
local gui = require("__flib__.gui-new")

event.on_init(function()
  gui.init()
  global.players = {}
end)

gui.register_handlers()

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local player_table = {}

  player_table.refs, player_table.assigned_handlers = gui.build(player.gui.screen, "demo", {
    {
      type = "button",
      style = "mod_gui_button",
      caption = "Count: 0",
      on_click = "increment",
      ref = {"buttons", "count"}
    }
  })

  player_table.count = 0

  global.players[e.player_index] = player_table
end)

function gui.updaters.demo(msg, e)
  if msg == "increment" then
    local player_table = global.players[e.player_index]
    player_table.count = player_table.count + 1
    player_table.refs.buttons.count.caption = "Count: "..player_table.count
  end
end