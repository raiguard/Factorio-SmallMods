local misc = require("__flib__.misc")

return function()
  return {"", {"statsgui.playtime"}, " = ", misc.ticks_to_timestring(game.ticks_played)}
end