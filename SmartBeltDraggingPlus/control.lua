local event = require("__flib__.event")

-- TODO
event.on_built_entity(function(e)
  local player = game.get_player(e.player_index)
  local entity = e.created_entity
  if entity and entity.valid and entity.type == "entity-ghost" and entity.ghost_type == "transport-belt" then
    if player.can_build_from_cursor{position = entity.position, direction = entity.direction} then
      player.build_from_cursor{position = entity.position, direction = entity.direction}
    end
  end
end)

event.register("sbdp-create-splitter", function(e)

end)
