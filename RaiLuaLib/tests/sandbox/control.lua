local delta = 1.10408951367 -- 7th root of 2

local function setup_player(i)
  global.players[i] = {
    zoom = 1
  }
end

script.on_init(function()
  global.players = {}
  for i,p in pairs(game.players) do
    setup_player(i)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  setup_player(e.player_index)
end)

script.on_event({'sandbox-zoom-in', 'sandbox-zoom-out', 'sandbox-zoom-in-extended', 'sandbox-zoom-out-extended'}, function(e)
  local player = game.get_player(e.player_index)
  if player.render_mode == defines.render_mode.game and player.controller_type ~= defines.controllers.editor then
    local player_table = global.players[e.player_index]
    local extended = e.input_name:find('extended') and true or false
    if e.input_name:find('in') then
      player_table.zoom = math.min(player_table.zoom * delta, (extended and 40 or 3))
    else
      player_table.zoom = math.max(player_table.zoom / delta, (extended and 0.1 or 0.5))
    end
    player.zoom = player_table.zoom
  end
end)