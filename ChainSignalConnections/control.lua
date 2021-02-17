local event = require("__flib__.event")

local function find_signal_connection_side(rail, signal)
  if rail.get_rail_segment_entity(defines.rail_direction.front, false) == signal then
    return defines.rail_direction.front, false
  elseif rail.get_rail_segment_entity(defines.rail_direction.front, true) == signal then
    return defines.rail_direction.front, true
  elseif rail.get_rail_segment_entity(defines.rail_direction.back, false) == signal then
    return defines.rail_direction.back, false
  elseif rail.get_rail_segment_entity(defines.rail_direction.back, true) == signal then
    return defines.rail_direction.back, true
  else
    assert(false)
  end
end

local function get_signal_rails(signal)
  assert(signal and (signal.type == "rail-signal" or signal.type == "rail-chain-signal"))
  local rails = signal.get_connected_rails()
  if #rails == 0 then
    return {to={},from={}}
  else
    local rail_direction, in_else_out = find_signal_connection_side(rails[1], signal)
    local otherRails = {}
    for _,connection_direction in pairs{defines.rail_connection_direction.left, defines.rail_connection_direction.straight, defines.rail_connection_direction.right} do
      local rail = rails[1].get_connected_rail{rail_direction=rail_direction, rail_connection_direction=connection_direction}
      if rail then
        table.insert(otherRails, rail)
      end
    end
    local from
    local to
    if in_else_out then
      from = otherRails
      to = rails
    else
      from = rails
      to = otherRails
    end
    return {
      to = to,
      from = from
    }
  end
end

event.on_init(function()
  global.players = {}

  for i in pairs(game.players) do
    global.players[i] = {}
  end
end)

event.on_selected_entity_changed(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local selected = player.selected

  if player_table.selected then
    player_table.selected = false
    for _, id in pairs(player_table.objects) do
      rendering.destroy(id)
    end
    player_table.objects = {}
  elseif selected and selected.valid and selected.type == "rail-chain-signal" then
    player_table.selected = true
    -- DEBUGGING
    local objects = {}
    -- input and output rails
    local rails = get_signal_rails(selected)
    for _, rail in ipairs(rails.to) do
      table.insert(objects, rendering.draw_circle{
        color = {g = 1},
        radius = 0.25,
        filled = true,
        target = rail.position,
        surface = rail.surface
      })
    end
    for _, rail in ipairs(rails.from) do
      table.insert(objects, rendering.draw_circle{
        color = {r = 1},
        radius = 0.25,
        filled = true,
        target = rail.position,
        surface = rail.surface
      })
    end
    -- -- direction to travel
    -- local rail = selected.get_connected_rails()[1]
    -- local rail_direction, in_else_out = find_signal_connection_side(rail, selected)
    -- local end_rail = rail.get_rail_segment_end(rail_direction)
    -- if end_rail then
    --   table.insert(objects, rendering.draw_circle{
    --     color = {b = 1},
    --     radius = 0.25,
    --     filled = true,
    --     target = end_rail.position,
    --     surface = end_rail.surface
    --   })
    -- end

    player_table.objects = objects
  end
end)