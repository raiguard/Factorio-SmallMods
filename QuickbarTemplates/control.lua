-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICKBAR TEMPLATES CONTROL SCRIPTING

 -- debug adapter
 pcall(require,'__debugadapter__/debugadapter.lua')

-- -----------------------------------------------------------------------------
-- UTILITIES

-- create the GUI
local function create_gui(player)
  local window = player.gui.screen.add{type='frame', name='qt_window', style='shortcut_bar_window_frame'}
  window.style.right_padding = 4
  local inner_panel = window.add{type='frame', name='qt_inner_panel', style='shortcut_bar_inner_panel'}
  local export_button = inner_panel.add{type='sprite-button', name='qt_export_button', style='shortcut_bar_button_blue', sprite='qt-export-blueprint-white',
                                        tooltip={'qt-gui.export'}}
  local import_button = inner_panel.add{type='sprite-button', name='qt_import_button', style='shortcut_bar_button_blue', sprite='qt-import-blueprint-white',
                                        tooltip={'qt-gui.import'}}
  window.visible = false
  return {window=window, export_button=export_button, import_button=import_button}
end

-- setup player global table and GUI
local function setup_player(player)
  local data = create_gui(player)
  global.players[player.index] = data
  return data.window
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

-- -----------------------------------------------------------------------------
-- QUICKBAR

-- export the current quickbar filters to a blueprint
local function export_quickbar(player)
  -- get quickbar filters
  local get_slot = player.get_quick_bar_slot
  local filters = {}
  for i=1,100 do
    local item = get_slot(i)
    if item and item.name ~= 'blueprint' and item.name ~= 'blueprint-book' then
      filters[i] = item.name
    end
  end
  -- assemble blueprint entities
  local entities = {}
  local pos = {x=-4,y=4}
  for i=1,100 do
    -- add blank combinator
    entities[i] = {
      entity_number = i,
      name = 'constant-combinator',
      position = {x=pos.x, y=pos.y},
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
              type = 'item'
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
local function import_quickbar(player, entities)
  -- error checking: should have exactly 100 entities
  if #entities ~= 100 then
    player.print{'qt-chat-message.invalid-blueprint'}
    return
  end
  -- assemble filters into a table
  local filters = {}
  for i=1,100 do
    local entity = entities[i]
    -- error checking: should be a constant combinator
    if entity == nil or entity.name ~= 'constant-combinator' then
      player.print{'qt-chat-message.invalid-blueprint'}
      return
    end
    -- get_blueprint_entities() does not return them in any particular order, so calculate the index by position
    local pos = entity.position
    local filter_index = 46 + (pos.x) + (-pos.y*10)
    if entity.control_behavior then
      -- error checking: should only have one filter
      if #entity.control_behavior.filters > 1 then
        player.print{'qt-chat-message.invalid-blueprint'}
        return
      end
      filters[filter_index] = entities[i].control_behavior.filters[1].signal.name
    else
      filters[filter_index] = ''
    end
  end
  local length = #filters
  -- due to floating point imprecision, we must check if all of the indexes are off by one, and compensate if so
  local offset = length == 101 and -1 or 0
  local start = length == 101 and 2 or 1
  -- apply the filters
  local set_filter = player.set_quick_bar_slot
  for i=start,length do
    local filter = filters[i]
    if filter == '' then filter = nil end
    set_filter(i+offset, filter)
  end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- on init
script.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    local window = setup_player(player)
  end
end)

-- when a player is created
script.on_event(defines.events.on_player_created, function(e)
  local player = game.players[e.player_index]
  setup_player(player)
  -- apply default template if one is set up
  local template = player.mod_settings['qt-default-template'].value
  if template ~= '' then
    -- put a blueprint into the cursor stack to retrieve a LuaItemStack object
    player.clean_cursor()
    local cursor_stack = player.cursor_stack
    cursor_stack.set_stack{name='blueprint'}
    local blueprint = cursor_stack
    -- error checking
    if not blueprint or blueprint.valid == false then
      player.print{'qt-chat-message.default-template-import-failed'}
      player.clean_cursor()
      return
    end
    -- import the default template
    if blueprint.import_stack(template) == 0 then
      -- apply to quickbar
      import_quickbar(player, blueprint.get_blueprint_entities())
    else
      -- error
      player.print{'qt-chat-message.invalid-default-blueprint'}
    end
    -- remove blueprint
    blueprint.clear()
  end
end)

-- when a player's cursor stack changes
-- separated so we can call it internally
local function on_cursor_stack_changed(e)
  local player = game.players[e.player_index]
  local gui = global.players[e.player_index]
  local stack = player.cursor_stack
  if stack and stack.valid_for_read and stack.name == 'blueprint' then
    -- show GUI
    set_gui_location(player, gui.window)
    if stack.is_blueprint_setup() then
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

-- when a player's display resolution or scale changes
script.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(e)
  set_gui_location(game.players[e.player_index], global.players[e.player_index].window)
end)

-- when a player clicks a GUI button
script.on_event(defines.events.on_gui_click, function(e)
  if e.element.name == 'qt_export_button' then
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'blueprint' then
      -- export to held blueprint
      stack.set_blueprint_entities(export_quickbar(player))
      -- update visible button
      on_cursor_stack_changed(e)
    end
  elseif e.element.name == 'qt_import_button' then
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'blueprint' then
      -- import from held blueprint
      import_quickbar(player, stack.get_blueprint_entities())
    end
  end
end)

-- DEBUGGING
if __DebugAdapter then
  script.on_event('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end