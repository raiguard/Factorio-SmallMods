-- ----------------------------------------------------------------------------------------------------
-- TEST EVENTS
-- Simply require the event handler like so, and you can use it! You can require it in multiple files locally without issues.

local event = require('scripts/event-handler')

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

-- could also use event.register(-6, function) if so desired
event.on_nth_tick(6, function(e)
    for _,player in pairs(game.players) do
        player.surface.create_entity{
            name = 'fire-flame',
            position = player.position
        }
    end
end)