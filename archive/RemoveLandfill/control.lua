local function get_prototypes()
    global.water_prototypes = {}
    for n,_ in pairs(game.get_filtered_tile_prototypes{{filter='collision-mask', mask='water-tile', mask_mode='collides'}}) do
        global.water_prototypes[n] = true
    end
    global.water_prototypes['water-shallow'] = nil
end

-- set up prototype lookup table
script.on_init(function(e)
    get_prototypes()
end)

-- set up prototype lookup table
script.on_configuration_changed(function(e)
    get_prototypes()
end)

-- TO FIX: Placing another tile over landfill, then removing that tile, will restore deep water!?

-- when landfill is mined, place shallow water beneath it
script.on_event({defines.events.on_player_mined_tile, defines.events.on_robot_mined_tile}, function(e)
    for _,t in pairs(e.tiles) do
        local pos = t.position
        local surface = game.surfaces[e.surface_index]
        if global.water_prototypes[surface.get_tile(pos.x, pos.y).name] then
            surface.set_tiles{{name='water-shallow', position=pos}}
        end
    end
end)