-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST EVENTS

local event = require('event')
local mod_gui = require('mod-gui')

-- can also use event.register('on_init', function) if so desired
event.on_init(function()
  log('on_init')
  global.players = {}
  global.chests = {}
end)

-- can also use event.on_configuration_changed(function) if so desired
event.register('on_configuration_changed', function(e)
  print(serpent.block(e))
end)

-- use shortcuts when we only want to listen to one event that's not custom
event.on_player_created(function(e)
  local player = game.players[e.player_index]
  if player.character then
  player.character.destructible = false
  end
  global.players[e.player_index] = {}
end)

-- listen to multiple events by defining them in an array
event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}, function(e)
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
event.on_gui_click(function(e)
  local player = game.players[e.player_index]
  player.print('[color=0,255,100]you clicked a demo button![/color]')
end, {gui_filters='reh_demo_button'})
-- clicked event for demo button 1
event.on_gui_click(function(e)
  local player = game.players[e.player_index]
  player.print('[color=255,100,0]you clicked the first demo button![/color]')
end, {gui_filters='reh_demo_button_1'})
-- clicked event for demo button 2
-- show/hide a mod GUI frame when clicked
event.on_gui_click(function(e)
  local player = game.players[e.player_index]
  local frame_flow = mod_gui.get_frame_flow(player)
  if frame_flow.reh_demo_window then
    -- close demo GUI
    frame_flow.reh_demo_window.destroy()
    -- deregister conditional event for the slider
    event.deregister(defines.events.on_gui_value_changed, set_daytime, {name='change_daytime_slider', player_index=e.player_index})
    -- remove slider from global
    global.players[e.player_index].slider = nil
  else
    -- create a demo GUI
    local window = frame_flow.add{type='frame', name='reh_demo_window', style=mod_gui.frame_style, direction='vertical', caption='REH Demo'}
    local slider = window.add{type='slider', name='reh_demo_slider', minimum_value=0, maximum_value=1, value=player.surface.daytime}
    -- register conditional event for the slider
    event.on_gui_value_changed(set_daytime, {name='change_daytime_slider', player_index=e.player_index, gui_filters=slider})
    -- add slider to global
    global.players[e.player_index].slider = slider
  end
end, {gui_filters='reh_demo_button_2'})

-- -----------------------------------------------------------------------------
-- CONDITIONAL EVENTS

-- -------------------------------------
-- GLOBAL
-- void the contents of all wooden chests on the map on every tick

local function void_chests_tick(e)
  for _,entity in pairs(global.chests) do
    -- remove all contents from all wooden chests on every tick
    local inventory = entity.get_inventory(defines.inventory.chest)
    inventory.clear()
  end
end

event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}, function(e)
  local entity = e.created_entity
  if entity.valid and entity.name == 'wooden-chest' then
    if table_size(global.chests) == 0 then
      -- register global conditional event
      event.register(defines.events.on_tick, void_chests_tick, {name='void_chests_tick'})
    end
    global.chests[entity.unit_number] = entity
  end
end)

event.register(
  {
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_entity_died,
    defines.events.script_raised_destroy
  },
  function(e)
    local entity = e.entity
    if entity.name == 'wooden-chest' then
      global.chests[entity.unit_number] = nil
      if table_size(global.chests) == 0 then
      -- deregister global conditional event
      event.deregister(defines.events.on_tick, void_chests_tick, {name='void_chests_tick'})
      end
    end
  end
)

-- -------------------------------------
-- PLAYER SPECIFIC
-- when the shortcut is active, place fire at the player's feet

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
    event.deregister(-6, place_fire, {name='place_fire_at_feet', player_index=e.player_index})
  else
    player.set_shortcut_toggled('toggle-fire-at-feet', true)
    -- use event.register to register the conditional event
    -- negative numbers can be used in place of using event.on_nth_tick()
    event.register(-6, place_fire, {name='place_fire_at_feet', player_index=e.player_index})
  end
end)

-- pass the handler in on_load to be re-registered if needed
event.on_load(function()
  event.load_conditional_handlers{
    place_fire_at_feet = place_fire,
    change_daytime_slider = set_daytime,
    void_chests_tick = void_chests_tick
  }
end)