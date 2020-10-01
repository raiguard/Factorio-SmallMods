local gui = require("__flib__.gui")

script.on_event(defines.events.on_player_created, function(e)
  local player = game.get_player(e.player_index)
  gui.build(player.gui.screen, {
    {type = "flow", style_mods = {padding = 0}, children = {
      {type = "frame", direction = "vertical", children = {
        {type = "button", caption = "Button"},
        {type = "label", caption = "Label"}
      }}
    }}
  })
end)