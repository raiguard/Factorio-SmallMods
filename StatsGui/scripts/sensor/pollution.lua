return function(settings, player)
  if not settings.show_pollution then return end
  return {
    "",
    {"statsgui.pollution"},
    string.format(" = %.2f", player.surface.get_pollution(player.position)),
    " PU"
  }
end
