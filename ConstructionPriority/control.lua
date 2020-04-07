-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROL SCRIPTING

-- dependencies
local math2d = require('__core__.lualib.math2d')

local function iterate_entities()
  local scans = global.scans
  local entities_per_tick = global.settings.entities_per_tick
  for pi,data in pairs(scans) do
    local start_index = data.next_index
    local end_index = start_index + entities_per_tick
    local reached_end = false
    local entities = data.entities
    local force = data.force
    local surface = data.surface
    for i=start_index,end_index do
      local entity = entities[i]
      if not entity then
        reached_end = true
        break
      end
      if entity.valid then
        if entity.name == 'entity-ghost' then
          -- revive and destroy ghost
          local _, new_entity = entity.silent_revive()
          if new_entity then
            new_entity.die(force)
          end
        elseif entity.name == 'item-request-proxy' then
          local position = entity.position
          local requests = entity.item_requests
          local target = entity.proxy_target
          entity.destroy()
          surface.create_entity{
            name = 'item-request-proxy',
            position = position,
            target = target,
            modules = requests,
            force = force,
          }
        elseif entity.to_be_deconstructed() then
          entity.cancel_deconstruction(force)
          entity.order_deconstruction(force, pi)
        elseif entity.to_be_upgraded() then
          local target = entity.get_upgrade_target()
          entity.cancel_upgrade(force)
          entity.order_upgrade{force=force, player=pi, target=target}
        end
      end
    end
    data.next_index = end_index + 1
    if reached_end then
      scans[pi] = nil
      if table_size(scans) == 0 then
        script.on_event(defines.events.on_tick, nil)
      end
    end
  end
end

script.on_init(function()
  global.scans = {}
  global.settings = {
    entities_per_tick = settings.global['cp-entities-per-tick'].value
  }
end)

script.on_load(function()
  if table_size(global.scans) > 0 then
    script.on_event(defines.events.on_tick, iterate_entities)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == 'cp-entities-per-tick' then
    global.settings.entities_per_tick = settings.global['cp-entities-per-tick'].value
  end
end)

script.on_event('cp-scan', function(e)
  local player = game.get_player(e.player_index)

  if player.character then
    local grid = player.character.grid
    if grid then
      -- get roboport range
      local range = 0
      local equipment = grid.equipment
      for i=1,#equipment do
        local obj = equipment[i]
        if obj.type == 'roboport-equipment' then
          range = range + obj.prototype.logistic_parameters.construction_radius
        end
      end

      if range > 0 then
        -- calculate dimensions and get entities
        local area = math2d.bounding_box.create_from_centre(player.position, range)
        local entities = player.surface.find_entities_filtered{area=area, force=player.force}

        if entities[1] then
          -- add data to global
          global.scans[e.player_index] = {
            area = area,
            entities = entities,
            force = player.force.name,
            next_index = 1,
            surface = player.surface
          }
  
          -- register event
          if not script.get_event_handler(defines.events.on_tick) then
            script.on_event(defines.events.on_tick, iterate_entities)
          end
        end
      end
    end
  end
end)