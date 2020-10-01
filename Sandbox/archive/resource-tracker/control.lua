local draw_text = rendering.draw_text
local clear = rendering.clear

script.on_nth_tick(10, function()
  clear()
  local nauvis = game.surfaces.nauvis
  local resources = nauvis.find_entities_filtered{
    type = "resource"
  }

  for _, resource in ipairs(resources) do
    draw_text{
      text = resource.amount,
      surface = nauvis,
      target = resource,
      color = {r=1, g=1, b=1},
    }
  end
end)