-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST EVENTS

local event = require("__flib__.control.event")
local mod_gui = require("mod-gui")

-- can also use event.register("on_init", function) if so desired
event.on_init(function()
  log("on_init")
  global.event = {}
  global.event.players = {}
  global.event.chests = {}
end)

-- can also use event.on_configuration_changed(function) if so desired
event.register("on_configuration_changed", function(e)
  print(serpent.block(e))
end)

-- use shortcuts when we only want to listen to one event that's not custom
event.on_player_created(function(e)
  local player = game.players[e.player_index]
  if player.character then
  player.character.destructible = false
  end
  global.event.players[e.player_index] = {}
end)

-- listen to multiple events by defining them in an array
event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}, function(e)
  local entity = e.created_entity
  entity.surface.create_entity{
    name = "highlight-box",
    position = entity.position,
    bounding_box = entity.selection_box,
    box_type = "electricity",
    render_player_index = e.player_index,
    blink_interval = 10,
    time_to_live = 50
  }
end)

-- custom inputs
event.register("demo-input", function(e)
  game.players[e.player_index].print("You shift+scrolled upwards on tick "..e.tick)
end)

-- nth tick
-- can also use event.register(-3600, handler)
event.on_nth_tick(3600, function(e)
  game.print("It has been one minute since I last spoke!")
end)

-- -----------------------------------------------------------------------------
-- CONDITIONAL EVENTS

-- -------------------------------------
-- GLOBAL
-- void the contents of all wooden chests on the map on every tick

local function void_chests_tick(e)
  for _,entity in pairs(global.event.chests) do
    -- remove all contents from all wooden chests on every tick
    local inventory = entity.get_inventory(defines.inventory.chest)
    inventory.clear()
  end
end

event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}, function(e)
  local entity = e.created_entity
  if entity.valid and entity.name == "wooden-chest" then
    if table_size(global.event.chests) == 0 then
      -- enable void chest event
      event.enable("void_chests_tick")
    end
    global.event.chests[entity.unit_number] = entity
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
    if entity.name == "wooden-chest" then
      global.event.chests[entity.unit_number] = nil
      if table_size(global.event.chests) == 0 then
      -- disable the void chest event
      event.disable("void_chests_tick")
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
      name = "fire-flame",
      position = player.position
    }
  end
end

-- when the fire shortcut is pressed
event.register(defines.events.on_lua_shortcut, function(e)
  local player = game.players[e.player_index]
  if player.is_shortcut_toggled("toggle-fire-at-feet") then
    player.set_shortcut_toggled("toggle-fire-at-feet", false)
    -- disable the conditional event for this player specifically
    event.disable("place_fire_at_feet", e.player_index)
  else
    player.set_shortcut_toggled("toggle-fire-at-feet", true)
    -- enable the conditional event for this player specifically
    event.enable("place_fire_at_feet", e.player_index)
  end
end)

-- -------------------------------------
-- REGISTRATION
-- conditional events are registered in the root scope, or in on_init and on_load, then enabled/disabled during runtime

-- register the conditional events to allow for save/load safety
event.register_conditional{
  place_fire_at_feet = {id=-6, handler=place_fire, options={skip_validation=true}},
  void_chests_tick = {id=defines.events.on_tick, handler=void_chests_tick}
}

-- -----------------------------------------------------------------------------
-- CUSTOM EVENTS

-- generate the event
-- you could also assign this to a local variable if desired
event.get_id("custom_event")

-- register a handler for the custom event
event.register(event.get_id("custom_event"), function(e)
  game.print("[color=0,255,255]Player "..e.player_index.." fired the custom event![/color]")
end)

-- the custom event can also be used conditionally just like any other event

-- -----------------------------------------------------------------------------
-- CONDITIONAL EVENT GROUPS
-- enable and disable events en masse

local custom_events = {}
for i=1,50 do
  custom_events["demo_"..i] = {id=-30, handler=function() log("DEMO "..i) end, group={"demo_group", math.floor(i/5)}}
end
event.register_conditional(custom_events)

event.on_player_created(function(e)
  local player = game.players[e.player_index]
  local button_flow = mod_gui.get_button_flow(player)
  button_flow.add{type="checkbox", name="reh_demo_button_3", caption="GROUPS", state=false}
end)

event.on_gui_checked_state_changed(function(e)
  if e.element and e.element.name == "reh_demo_button_3" then
    if e.element.state == true then
      event.enable_group(1)
      event.enable_group(3)
      event.enable_group(4)
    else
      event.disable_group("demo_group")
    end
  end
end)