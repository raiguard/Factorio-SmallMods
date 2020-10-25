local event = require("__flib__.event")

local function check_stack(player)
  local cursor_stack = player.cursor_stack
  local cursor_ghost = player.cursor_ghost
  if cursor_stack and cursor_stack.valid_for_read then
    return cursor_stack.name
  elseif cursor_ghost then
    return cursor_ghost.name
  else
    return
  end
end

event.register("pg-activate-guide", function(e)
  local player = game.get_player(e.player_index)
  local held_item = check_stack(player)

  if held_item then
    local item_prototype = game.item_prototypes[held_item]
    local entity_prototype = item_prototype.place_result
    if
      entity_prototype
      and entity_prototype.has_flag("player-creation")
      and not entity_prototype.has_flag("not-blueprintable")
    then
      if player.clear_cursor() then
        -- create placement guide
        local cursor_stack = player.cursor_stack
        cursor_stack.set_stack{name = "pg-guide"}
        cursor_stack.set_blueprint_entities{
          {
            entity_number = 1,
            name = entity_prototype.name,
            position = {0, 0}
          }
        }
        cursor_stack.blueprint_icons = {
          {signal = {type = "item", name = held_item}, index = 1}
        }
        cursor_stack.label = tostring(player.get_main_inventory().get_item_count(held_item))

        -- TODO set the grid...
      else
        -- the game will create flying text for us
        player.play_sound{path = "utility/cannot_build"}
      end
    end
  end
end)

event.on_pre_build(function(e)
  -- TODO replace ghost with real entity if not in editor and has the item
  -- TODO update count in label
end)