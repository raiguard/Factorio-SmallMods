local function run_search(player_index)
  local player = game.get_player(player_index)
  local force = player.force
  local surface = player.surface

  local ghosts = surface.find_entities_filtered{
    force = player.force,
    position = player.position,
    radius = player.mod_settings["gh-search-radius"].value,
    type = "entity-ghost"
  }

  for _, ghost in ipairs(ghosts) do
    surface.create_entity{
      name = "gh-highlight-box",
      position = ghost.position,
      force = force,
      player = player,
      bounding_box = ghost.selection_box,
      render_player_index = player_index,
      blink_interval = 10,
      time_to_live = 180
    }
  end
end

script.on_event("gh-run-search", function(e)
  run_search(e.player_index)
end)

script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == "gh-run-search" then
    run_search(e.player_index)
  end
end)