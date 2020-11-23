-- create the GUI
local function create_gui(player)
  local window = player.gui.screen.add{type = "frame", name = "qt_window", style = "quick_bar_window_frame"}
  local inner_panel = window.add{type = "frame", name = "qt_inner_panel", style = "shortcut_bar_inner_panel"}
  local export_button = inner_panel.add{
    type = "sprite-button",
    name = "qt_export_button",
    style = "shortcut_bar_button_blue",
    sprite = "qt-export-blueprint-white",
    tooltip={"qt-gui.export"}
  }
  local import_button = inner_panel.add{
    type = "sprite-button",
    name = "qt_import_button",
    style = "shortcut_bar_button_blue",
    sprite = "qt-import-blueprint-white",
    tooltip={"qt-gui.import"}
  }
  window.visible = false
  return {window = window, export_button = export_button, import_button = import_button}
end

-- setup player global table and GUI
local function setup_player(player)
  local data = create_gui(player)
  global.players[player.index] = data
end

-- set window location relative to the player's quickbar
local function set_gui_location(player, window)
  local resolution = player.display_resolution
  local scale = player.display_scale
  window.location = {
    x = (resolution.width / 2) - ((56 + 258) * scale),
    y = (resolution.height - (56 * scale))
  }
end

local function round(value)
  return math.floor(value + 0.5)
end

-- convert an entity position to quickbar index
-- tags are still used whenever possible, this is a backup option
local function position_to_index(position, zero_position)
  local result = round(position.x - zero_position.x) + round(zero_position.y - position.y) * 10 + 1
  return result
end

-- get the center of a blueprint
local function get_zero_position(entities)
  local result = {x = entities[1].position.x, y = entities[1].position.y}
  for i = 2, 100 do
    local position = entities[i].position
    if result.x > position.x then result.x = position.x end
    if result.y < position.y then result.y = position.y end
  end
  return result
end

-- export the current quickbar filters to a blueprint
local function export_quickbar(player)
  -- get quickbar filters
  local get_slot = player.get_quick_bar_slot
  local filters = {}
  for i = 1, 100 do
    local item = get_slot(i)
    if item and item.name ~= "blueprint" and item.name ~= "blueprint-book" then
      filters[i] = item.name
    end
  end
  -- assemble blueprint entities
  local entities = {}
  local pos = {x = -4, y = 4}
  for i = 1, 100 do
    -- add blank combinator
    entities[i] = {
      entity_number = i,
      name = "constant-combinator",
      position = {x = pos.x, y = pos.y},
      tags = {QuickbarTemplates = i}
    }
    -- set combinator signal if there's a filter
    if filters[i] ~= nil then
      entities[i].control_behavior = {
        filters = {
          {
            count = 1,
            index = 1,
            signal = {
              name = filters[i],
              type = "item"
            }
          }
        }
      }
    end
    -- adjust position for next entity
    pos.x = pos.x + 1
    if pos.x == 6 then
      pos.x = -4
      pos.y = pos.y - 1
    end
  end
  return entities
end

-- apply the filters from the given blueprint to our quickbar
local function import_quickbar(player, entities, ignore_empty)
  -- error checking: should have exactly 100 entities
  if #entities ~= 100 then
    player.print{"qt-message.invalid-blueprint"}
    return
  end
  -- assemble filters into a table
  local filters = {}
  local zero_position = get_zero_position(entities)
  for i = 1, 100 do
    local entity = entities[i]
    -- error checking: should be a constant combinator
    if entity == nil or entity.name ~= "constant-combinator" then
      player.print{"qt-message.invalid-blueprint"}
      return
    end
    local filter_index = (entity.tags or {}).QuickbarTemplates or position_to_index(entity.position, zero_position)
    if entity.control_behavior then
      -- error checking: should only have one filter
      if #entity.control_behavior.filters > 1 then
        player.print{"qt-message.invalid-blueprint"}
        return
      end
      filters[filter_index] = entities[i].control_behavior.filters[1].signal.name
    else
      filters[filter_index] = ""
    end
  end
  local length = #filters
  -- due to floating point imprecision, we must check if all of the indexes are off by one, and compensate if so
  local offset = length == 101 and -1 or 0
  local start = length == 101 and 2 or 1
  -- apply the filters
  local set_filter = player.set_quick_bar_slot
  for i = start, length do
    local filter = filters[i]
    if not ignore_empty or filter ~= "" then
      set_filter(i + offset, filter ~= "" and filter or nil)
    end
  end
end

-- EVENT HANDLERS

script.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
end)

script.on_configuration_changed(function()
  for i, player_table in pairs(global.players) do
    player_table.window.destroy()
    local player = game.get_player(i)
    if player then
      global.players[i] = create_gui(player)
    else
      -- clean up unneeded tables
      global.players[i] = nil
    end
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  local player = game.players[e.player_index]
  setup_player(player)
  -- apply default template if one is set up
  local template = player.mod_settings["qt-default-template"].value
  if template ~= "" then
    -- create inventory and insert a blueprint
    local inventory = game.create_inventory(1)
    inventory.insert{name="blueprint"}
    local blueprint = inventory[1]

    -- import the default template
    if blueprint.import_stack(template) == 0 then
      -- apply to quickbar
      import_quickbar(player, blueprint.get_blueprint_entities())
    else
      -- error
      player.print{"qt-message.invalid-default-blueprint"}
    end

    -- destroy inventory
    inventory.destroy()
  end
end)

local function on_cursor_stack_changed(e)
  local player = game.players[e.player_index]
  local gui = global.players[e.player_index]
  if player.is_cursor_blueprint() then
    -- show GUI
    set_gui_location(player, gui.window)
    local entities = player.get_blueprint_entities()
    if entities then
      gui.export_button.visible = false
      gui.import_button.visible = true
    else
      gui.export_button.visible = true
      gui.import_button.visible = false
    end
    gui.window.visible = true
  elseif gui.window.visible then
    -- hide GUI
    gui.window.visible = false
  end
end
script.on_event(defines.events.on_player_cursor_stack_changed, on_cursor_stack_changed)

script.on_event(
  {
    defines.events.on_player_display_resolution_changed,
    defines.events.on_player_display_scale_changed
  },
  function(e)
    set_gui_location(game.players[e.player_index], global.players[e.player_index].window)
  end
)

script.on_event(defines.events.on_gui_click, function(e)
  if e.element.name == "qt_export_button" then
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == "blueprint" then
      -- export to held blueprint
      stack.set_blueprint_entities(export_quickbar(player))
      -- update visible button
      on_cursor_stack_changed(e)
    end
  elseif e.element.name == "qt_import_button" then
    local player = game.players[e.player_index]
    local entities = player.get_blueprint_entities()
    if entities then
      -- import from held blueprint
      import_quickbar(player, entities, e.shift)
    end
  end
end)