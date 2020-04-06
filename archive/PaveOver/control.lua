-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROL SCRIPTING

-- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

local function pos_to_tile_area(pos)
  return {left_top=pos, right_bottom={x=pos.x+1, y=pos.y+1}}
end

script.on_init(function(e)
  global.tiles = {}
end)

-- when a player or a robot builds a tile
script.on_event({defines.events.on_player_built_tile, defines.events.on_robot_built_tile}, function(e)
  local mineable_properties = e.tile.mineable_properties
  -- check if the current tile is a "player construct", a.k.a removes decoratives
  if mineable_properties and mineable_properties.minable then
    local tiles = e.tiles
    local registry = global.tiles
    local surface = game.surfaces[e.surface_index]
    local find = surface.find_entities_filtered
    for ti=1,#tiles do
      local tile = tiles[ti]
      local pos = tile.position
      -- check for the tile in the registry
      if not registry[pos.x] or not registry[pos.x][pos.y] then
        -- if we paved over a resource, remove it and add it to the data
        local resources = find{area=pos_to_tile_area(pos), type='resource'}
        local rs = #resources
        if rs > 0 then
          local data = {tile=tile.old_tile.name}
          local t = {}
          for ri=1,rs do
            local resource = resources[ri]
            t[ri] = {name=resource.name, amount=resource.amount, position=resource.position}
            resource.destroy()
          end
          data.resources = t
          -- add the data to the registry
          if not registry[pos.x] then registry[pos.x] = {} end
          registry[pos.x][pos.y] = data
        end
      end
    end
  end
end)

-- when a player or a robot removes a tile
script.on_event({defines.events.on_player_mined_tile, defines.events.on_robot_mined_tile}, function(e)
  local tiles = e.tiles
  local registry = global.tiles
  local surface = game.surfaces[e.surface_index]
  local get = surface.get_tile
  local place = surface.create_entity
  for ti=1,#tiles do
    local tile = tiles[ti]
    local pos = tile.position
    -- check if it's in the registry
    local data = registry[pos.x] and registry[pos.x][pos.y] or nil
    if data then
      -- check the tile to see if it's been restored to the original
      local new_tile = get(pos.x, pos.y)
      if new_tile.name == data.tile then
        -- restore the resources that were here
        local resources = data.resources
        local rs = #resources
        for ri=1,rs do
          local resource = resources[ri]
          place{name=resource.name, position=resource.position, amount=resource.amount}
        end
      end
      registry[pos.x][pos.y] = nil
    end
  end
end)

-- DEBUGGING
if __DebugAdapter then
  script.on_event('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end