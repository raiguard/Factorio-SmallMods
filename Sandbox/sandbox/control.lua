local event = require("__flib__.event")

event.on_selected_entity_changed(function(e)
  if e.last_entity then
    rendering.destroy(global.module_bonus)
    rendering.destroy(global.lab_bonus)
  end
  local player = game.get_player(e.player_index)
  local entity = player.selected
  if entity then
    global.module_bonus = rendering.draw_text{
      text = entity.speed_bonus,
      surface = player.surface,
      target = entity,
      color = {r=1, g=1, b=1}
    }
    global.lab_bonus = rendering.draw_text{
      text = player.force.laboratory_speed_modifier,
      surface = player.surface,
      target = entity,
      target_offset = {0, 0.5},
      color = {r=1, g=1, b=1}
    }
  end
end)