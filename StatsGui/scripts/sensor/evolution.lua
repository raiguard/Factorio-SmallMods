return function()
  local evolution = game.forces.enemy.evolution_factor * 100
  return {
    "",
    {"statsgui.evolution"},
    string.format(" = %.2f", evolution),
    " %"
  }
end
