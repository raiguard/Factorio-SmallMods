local event = require("__flib__.control.event")

event.on_tick(function(e)
  game.print(e.tick)
end)