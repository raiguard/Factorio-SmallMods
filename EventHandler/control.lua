-- ----------------------------------------------------------------------------------------------------
-- TEST EVENTS

local event = require('event-handler')

-- can also use event.register('on_init', function) if so desired
event.on_init(function()
    log('on_init')
end)

-- can also use event.on_configuration_changed(function) if so desired
event.register('on_configuration_changed', function(e)
    print(serpent.block(e))
end)

event.register(defines.events.on_player_created, function(e)
    local player = game.players[e.player_index]
    if player.character then
        player.character.destructible = false
    end
end)

-- handler supports event tables, and even tables in tables (in case you're insane like that...)
event.register({defines.events.on_built_entity, {defines.events.on_robot_built_entity, defines.events.script_raised_built}}, function(e)
    local player = game.players[e.player_index]
    local entity = e.created_entity
    entity.surface.create_entity{
        name = 'highlight-box',
        position = entity.position,
        bounding_box = entity.selection_box,
        box_type = 'electricity',
        render_player_index = e.player_index,
        blink_interval = 10,
        time_to_live = 50
    }
end)

-- just to show that you can register multiple handlers to an event
event.register(defines.events.on_built_entity, function(e)
    local player = game.players[e.player_index]
    player.print('Built at coordinates '..serpent.line(e.created_entity.position))
end)

-- custom inputs
event.register('demo-input', function(e)
    game.players[e.player_index].print('You shift+scrolled upwards on tick '..e.tick)
end)

-- nth tick
event.on_nth_tick(3600, function(e)
    game.print('It has been one minute since I last spoke!')
end)

-- --------------------------------------------------
-- CONDITIONAL EVENTS

-- places fire at the player's feet
local function place_fire(e)
    for _,player in pairs(game.players) do
        player.surface.create_entity{
            name = 'fire-flame',
            position = player.position
        }
    end
end

-- when the fire lua shortcut is pressed
event.register(defines.events.on_lua_shortcut, function(e)
    local player = game.players[e.player_index]
    if player.is_shortcut_toggled('toggle-fire-at-feet') then
        player.set_shortcut_toggled('toggle-fire-at-feet', false)
        -- use event.deregister to deregister the conditional event
        -- pass the event's unique conditional event name as the third argument
        event.deregister(-6, place_fire, 'place_fire_at_feet')
    else
        player.set_shortcut_toggled('toggle-fire-at-feet', true)
        -- use event.register to register the conditional event
        -- pass a unique conditional event name as the third argument
        -- negative numbers can be used in place of using event.on_nth_tick()
        event.register(-6, place_fire, 'place_fire_at_feet')
    end
end)

-- pass the handler in on_load to be re-registered if needed
event.on_load(function()
    event.load_conditional_events{
        place_fire_at_feet = place_fire
    }
end)