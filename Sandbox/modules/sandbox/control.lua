local event = require("__flib__.event")
local gui = require("__flib__.gui")

event.on_player_created(function(e)
  local indicators = {}

  for i, color in ipairs{"black", "white", "red", "orange", "yellow", "green", "cyan", "blue", "purple", "pink"} do
    indicators[i] = {type = "flow", style = "flib_indicator_flow", children = {
      {type = "sprite", style = "flib_indicator", sprite = "flib_indicator_"..color},
      {type = "label", caption = color}
    }}
  end

  local player = game.get_player(e.player_index)
  gui.build(player.gui.screen, {
    {type = "frame", style_mods = {top_padding = 12}, children = {
      {type = "frame", style = "inside_shallow_frame_with_padding", children = indicators}
    }}
  })
end)