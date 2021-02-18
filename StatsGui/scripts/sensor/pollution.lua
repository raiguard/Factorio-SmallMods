return function(player)
  return {
    "",
    {"statsgui.pollution"},
    string.format(" = %.2f", player.surface.get_pollution(player.position)),
    " PU"
  }
end
