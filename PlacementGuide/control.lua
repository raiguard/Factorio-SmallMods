local event = require("__flib__.event")

-- -----------------------------------------------------------------------------
-- UTILITIES

local MIN_GUIDE_MARGIN = 3

local unsupported_entity_types = {
  ["artillery-wagon"] = true,
  ["car"] = true,
  ["cargo-wagon"] = true,
  ["fluid-wagon"] = true,
  ["locomotive"] = true,
  ["spidertron"] = true,
  ["tank"] = true
}

local function check_stack(player)
  local cursor_stack = player.cursor_stack
  local cursor_ghost = player.cursor_ghost
  if cursor_stack and cursor_stack.valid_for_read then
    local name = cursor_stack.name
    if name == "pg-guide" then
      -- Cursor Enhancements will recall last item but won't get the icon
      local icon = cursor_stack.blueprint_icons[1]
      if icon then
        return icon.signal.name, true
      else
        player.clear_cursor()
      end
    else
      return name
    end
  elseif cursor_ghost then
    return cursor_ghost.name, false, true
  else
    return
  end
end

local function set_label(player, item_name, is_ghost)
  local count = player.get_main_inventory().get_item_count(item_name)
  if is_ghost then
    player.cursor_stack.label = "[img=utility/ghost_cursor]"
  else
    player.cursor_stack.label = tostring(count)
  end
  return count
end

local function get_dimensions(area)
  return {
    height = math.abs(area.right_bottom.y - area.left_top.y),
    width = math.abs(area.right_bottom.x - area.left_top.x)
  }
end

local function setup_guide(player, item_name, entity_prototype, orientation, is_ghost)
  local dimensions = get_dimensions(entity_prototype.selection_box)
  -- set stack
  local cursor_stack = player.cursor_stack
  cursor_stack.set_stack{name = "pg-guide"}

  -- set entity
  local position
  local guide_margin
  if orientation == 0 then
    guide_margin = math.max(dimensions.width, MIN_GUIDE_MARGIN)
    position = {(dimensions.width + (guide_margin * 2) / 2) - (dimensions.width / 2), dimensions.height / 2}
  elseif orientation == 1 then
    guide_margin = math.max(dimensions.height, MIN_GUIDE_MARGIN)
    position = {dimensions.width / 2, (dimensions.height + (guide_margin * 2) / 2) - (dimensions.height / 2)}
  end
  cursor_stack.set_blueprint_entities{
    {
      entity_number = 1,
      name = entity_prototype.name,
      position = position
    }
  }

  -- set grid size
  cursor_stack.blueprint_snap_to_grid = {
    x = dimensions.width + (guide_margin * (orientation == 0 and 2 or 0)),
    y = dimensions.height + (guide_margin * (orientation == 1 and 2 or 0))
  }

  -- set icon
  cursor_stack.blueprint_icons = {
    {signal = {type = "item", name = item_name}, index = 1}
  }

  -- set label
  set_label(player, item_name, is_ghost)
end

local function positions_different(pos1, pos2)
  return pos1.x ~= pos2.x or pos1.y ~= pos2.y
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  global.players = {}

  for i in pairs(game.players) do
    global.players[i] = {
      building = false,
      is_ghost = false,
      last_error_position = {x = 0, y = 0},
      orientation = 0
    }
  end
end)

-- CUSTOM INPUT

event.register("pg-activate-guide", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local item_name, is_guide, is_ghost = check_stack(player)

  if item_name then
    if is_guide then
      -- swap grid dimensions
      player.clear_cursor()
      local item_prototype = game.item_prototypes[item_name]
      local entity_prototype = item_prototype.place_result
      player_table.orientation = math.abs(player_table.orientation - 1)
      setup_guide(player, item_name, entity_prototype, player_table.orientation, player_table.is_ghost)
    else
      -- create new guide
      local item_prototype = game.item_prototypes[item_name]
      local entity_prototype = item_prototype.place_result

      if entity_prototype then
        if
          not unsupported_entity_types[entity_prototype.type]
          and entity_prototype.has_flag("player-creation")
          and not entity_prototype.has_flag("not-blueprintable")
        then
          if player.clear_cursor() then
            setup_guide(player, item_name, entity_prototype, 0, is_ghost)
            player_table.is_ghost = is_ghost
            player_table.orientation = 0
          end
        else
          player.create_local_flying_text{
            text = {"pg-message.unsupported-entity"},
            create_at_cursor = true
          }
          player.play_sound{path = "utility/cannot_build"}
        end
      else
        player.create_local_flying_text{
          text = {"pg-message.item-has-no-entity"},
          create_at_cursor = true
        }
        player.play_sound{path = "utility/cannot_build"}
      end
    end
  end
end)

-- ENTITY

event.on_pre_build(function(e)
  if e.shift_build then return end

  local player = game.get_player(e.player_index)
  local _, is_guide = check_stack(player)
  if is_guide then
    global.players[e.player_index].building = true
  end
end)

event.on_built_entity(function(e)
  local player_table = global.players[e.player_index]
  if player_table.building then
    player_table.building = false

    local entity = e.created_entity
    local player = game.get_player(e.player_index)

    local is_ghost = entity.name == "entity-ghost"

    -- get item name
    local item_name = check_stack(player)
    if not item_name then return end

    -- get required item count
    local required_count
    local prototype = game.entity_prototypes[is_ghost and entity.ghost_name or entity.name]
    for _, stack in ipairs(prototype.items_to_place_this) do
      if stack.name == item_name then
        required_count = stack.count
        break
      end
    end
    if not required_count then return end

    -- check item count in inventory
    local main_inventory = player.get_main_inventory()
    local item_count = main_inventory.get_item_count(item_name)
    if item_count >= required_count then
      if is_ghost then
        -- check reach distance and other factors
        if
          player.can_place_entity{
            name = entity.ghost_name,
            position = entity.position,
            direction = entity.direction
          }
        then
          -- remove items from inventory and revive entity
          main_inventory.remove{name = item_name, count = required_count}
          local _, success = entity.revive{raise_revive = true}
          -- if it was not revived, destroy the ghost
          if not success then
            entity.destroy()
          end
        else
          if positions_different(entity.position, player_table.last_error_position) then
            player_table.last_error_position = entity.position
            player.create_local_flying_text{
              text = {"cant-reach"},
              position = entity.position
            }
            player.play_sound{path = "utility/cannot_build"}
          end
          entity.destroy()
        end
      else
        -- just remove the items
        main_inventory.remove{name = item_name, count = required_count}
      end
    end
  end
end)

-- INVENTORY

event.on_player_main_inventory_changed(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local item_name, is_guide = check_stack(player)
  if is_guide and not player_table.is_ghost then
    local new_count = set_label(player, item_name)
    if new_count == 0 then
      player.clear_cursor()
    end
  end
end)

-- PLAYER DATA

event.on_player_created(function(e)
  global.players[e.player_index] = {
    building = false,
    is_ghost = false,
    last_error_position = {x = 0, y = 0},
    orientation = 0
  }
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)
