-- ----------------------------------------------------------------------------------------------------
-- TEST EVENTS

local event = require('event')
local mod_gui = require('mod-gui')

-- can also use event.register('on_init', function) if so desired
event.on_init(function()
    log('on_init')
    global.players = {}
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
    global.players[e.player_index] = {}
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
-- can also use event.register(-3600, handler)
event.on_nth_tick(3600, function(e)
    game.print('It has been one minute since I last spoke!')
end)

-- --------------------------------------------------
-- GUI EVENTS

-- change daytime depending on value of slider
-- conditionally registered if the GUI is open
local function set_daytime(e)
    local surface = game.players[e.player_index].surface
    surface.daytime = e.element.slider_value
    -- update other players' sliders
    for _,i in pairs(e.registered_players) do
        if i ~= e.player_index then
            global.players[i].slider.slider_value = e.element.slider_value
        end
    end
end

-- create some demo buttons
event.register(defines.events.on_player_created, function(e)
    local player = game.players[e.player_index]
    local button_flow = mod_gui.get_button_flow(player)
    button_flow.add{type='button', name='reh_demo_button_1', style=mod_gui.button_style, caption='DEMO1'}
    button_flow.add{type='button', name='reh_demo_button_2', style=mod_gui.button_style, caption='DEMO2'}
end)
-- a clicked event for both buttons
event.gui.register({name_match={'reh_demo_button'}}, defines.events.on_gui_click, function(e)
    local player = game.players[e.player_index]
    player.print('[color=0,255,100]you clicked a demo button![/color]')
end)
-- clicked event for demo button 1
-- shortcutting: using just the element's name as the filter will work!
-- further shortcutting: for a given GUI event (except on_gui_opened and on_gui_closed), omit the "gui" part of the event name, and you can use it as the function call
event.gui.on_click('reh_demo_button_1', function(e)
    local player = game.players[e.player_index]
    player.print('[color=255,100,0]you clicked the first demo button![/color]')
end)
-- clicked event for demo button 2
-- show/hide a mod GUI frame when clicked
event.gui.register('reh_demo_button_2', defines.events.on_gui_click, function(e)
    local player = game.players[e.player_index]
    local frame_flow = mod_gui.get_frame_flow(player)
    if frame_flow.reh_demo_window then
        -- close demo GUI
        frame_flow.reh_demo_window.destroy()
        -- deregister conditional event for the slider
        event.gui.deregister(defines.events.on_gui_value_changed, set_daytime, 'change_daytime_slider', e.player_index)
        -- remove slider from global
        global.players[e.player_index].slider = nil
    else
        -- create a demo GUI
        local window = frame_flow.add{type='frame', name='reh_demo_window', style=mod_gui.frame_style, direction='vertical', caption='REH Demo'}
        local slider = window.add{type='slider', name='reh_demo_slider', minimum_value=0, maximum_value=1, value=player.surface.daytime}
        -- register conditional event for the slider
        event.gui.register({element={slider}}, defines.events.on_gui_value_changed, set_daytime, 'change_daytime_slider', e.player_index)
        -- add slider to global
        global.players[e.player_index].slider = slider
    end
end)

-- --------------------------------------------------
-- CONDITIONAL EVENTS

-- places fire at the player's feet
local function place_fire(e)
    -- use the registered_players table that is passed with conditional events
    for _,i in pairs(e.registered_players) do
        local player = game.players[i]
        player.surface.create_entity{
            name = 'fire-flame',
            position = player.position
        }
    end
end

-- when the fire shortcut is pressed
event.register(defines.events.on_lua_shortcut, function(e)
    local player = game.players[e.player_index]
    if player.is_shortcut_toggled('toggle-fire-at-feet') then
        player.set_shortcut_toggled('toggle-fire-at-feet', false)
        -- use event.deregister to deregister the conditional event
        -- pass the event's unique conditional event name as the third argument
        event.deregister(-6, place_fire, 'place_fire_at_feet', e.player_index)
    else
        player.set_shortcut_toggled('toggle-fire-at-feet', true)
        -- use event.register to register the conditional event
        -- pass a unique conditional event name as the third argument
        -- pass the player index as the fourth argument
        -- negative numbers can be used in place of using event.on_nth_tick()
        event.register(-6, place_fire, 'place_fire_at_feet', e.player_index)
    end
end)

-- pass the handler in on_load to be re-registered if needed
event.on_load(function()
    event.load_conditional_handlers{
        place_fire_at_feet = place_fire,
        change_daytime_slider = set_daytime
    }
end)