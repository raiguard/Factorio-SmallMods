local event = require("__flib__.event")

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local inventory = game.create_inventory(1)
  inventory[1].set_stack{name = "test-blueprint-book", count = 1}
  player.opened = inventory[1]
end)