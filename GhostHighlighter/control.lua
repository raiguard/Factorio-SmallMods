local event = require("__flib__.event")

-- -----------------------------------------------------------------------------
-- FUNCTIONS

local position = {}

function position.equals(pos1, pos2)
  return pos1.x == pos2.x and pos1.y == pos2.y
end

function position.floor(pos)
  pos.x = math.floor(pos.x)
  pos.y = math.floor(pos.y)
  return pos
end

local function setup_player(player_index)
  local player = game.get_player(player_index)
  global.players[player_index] = {
    boxes = {},
    enabled = false,
    last_position = position.floor(player.position)
  }
end

local function toggle_search(player_index, show_message)
  local player = game.get_player(player_index)
  local player_table = global.players[player_index]
  player_table.enabled = not player_table.enabled
  player.set_shortcut_toggled("gh-toggle-search", player_table.enabled)
  if show_message then
    player.print{"gh-message.search-"..(player_table.enabled and "enabled" or "disabled")}
    -- TODO in 1.1, use flying text instead
  end
end

-- for now, simply destroy and recreate boxes every time
-- optimize to preserve existing boxes later

local function run_search(player, player_table)
  local boxes = player_table.boxes

  -- destroy all boxes (temporary)
  for unit_number, box in pairs(boxes) do
    box.destroy()
    boxes[unit_number] = nil
  end

  local ghosts = player.surface.find_entities_filtered{
    force = player.force,
    position = player.position,
    radius = player.mod_settings["gh-search-radius"].value,
    type = "entity-ghost"
  }

  for _, ghost in ipairs(ghosts) do
    boxes[ghost.unit_number] = player.surface.create_entity{
      name = "gh-highlight-box",
      position = ghost.position,
      force = player.force,
      player = player,
      bounding_box = ghost.selection_box,
      render_player_index = player.index,
      blink_interval = 30
    }
  end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  global.players = {}

  for i in pairs(game.players) do
    setup_player(i)
  end
end)

-- PLAYER

event.on_player_created(function(e)
  setup_player(e.player_index)
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.on_player_changed_position(function(e)
  local player_table = global.players[e.player_index]
  if player_table.enabled then
    local player = game.get_player(e.player_index)
    -- check against last tile position
    local player_pos = position.floor(player.position)
    if not position.equals(player_pos, player_table.last_position) then
      player_table.last_position = player_pos
      run_search(player, player_table)
    end
  end
end)

-- SHORTCUT

event.register({"gh-toggle-search", defines.events.on_lua_shortcut}, function(e)
  if (e.input_name or e.prototype_name) == "gh-toggle-search" then
    toggle_search(e.player_index)
  end
end)