local event = require("__flib__.event")
local gui = require("__flib__.gui")

event.on_init(function()
  gui.init()
  gui.build_lookup_tables()
end)

event.on_load(function()
  gui.build_lookup_tables()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local display_scale = player.display_scale

  local root = player.gui.goal
  root.clear()

  gui.build(root, {
    {type="frame", children={
      {type="flow", style_mods={width=math.max(384 / display_scale, 300), horizontal_align="center"}, direction="vertical", children={

      }}
    }}
  })
end)