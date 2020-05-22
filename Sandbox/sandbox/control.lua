local event = require("__flib__.event")

event.on_init(function()
  local nauvis = game.surfaces.nauvis
  nauvis.generate_with_lab_tiles = true
  nauvis.clear(true)
  local read = nauvis.generate_with_lab_tiles
  log("STATE: "..tostring(read))
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  player.gui.top.add{type="checkbox", name="sandbox", caption="Toggle", state=true}
end)

event.on_gui_checked_state_changed(function(e)
  if e.element.name == "sandbox" then
    game.surfaces.nauvis.generate_with_lab_tiles = e.element.state
  end
end)