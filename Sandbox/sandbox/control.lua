local event = require("__flib__.event")

event.on_init(function()
  for i = 1, 1000 do
    game.create_force(i)
  end
end)