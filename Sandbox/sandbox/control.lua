local event = require("__flib__.event")
local gui = require("__flib__.gui")

event.on_player_created(function(e)
  gui.build(game.get_player(e.player_index).gui.screen, {
    {type="frame", children={
      {type="slider", style="notched_slider", minimum_value=1, maximum_value=2, value_step=1, discrete_slider=true, discrete_values=true}
    }}
  })
end)