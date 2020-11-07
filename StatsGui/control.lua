local event = require("__flib__.event")

local player_data = require("scripts.player-data")

local stats_gui = require("scripts.gui.stats")

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  global.players = {}
  for i, player in pairs(game.players) do
    player_data.init(i, player)
    player_data.refresh(player, global.players[i])
  end
end)

event.on_configuration_changed(function()
  for i, player in pairs(game.players) do
    player_data.refresh(player, global.players[i])
  end
end)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  player_data.init(e.player_index, player)
  player_data.refresh(player, global.players[e.player_index])
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.register(
  {
    defines.events.on_player_display_resolution_changed,
    defines.events.on_player_display_scale_changed
  },
  function(e)
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    stats_gui.set_size(player, player_table)
  end
)

-- TICK

-- update stats once per second
event.on_nth_tick(60, function()
  for i, player_table in pairs(global.players) do
    if player_table.gui.stats then
      stats_gui.update(game.get_player(i), player_table)
    end
  end
end)