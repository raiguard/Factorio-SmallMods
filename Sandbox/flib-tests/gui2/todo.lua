local gui = require("__flib__.gui2")
local table = require("__flib__.table")

local component = gui.component("todo")

function component.init()
  return {
    new_todo_text = "",
    todos = {},
    visible = true
  }
end

function component.update(player_index, msg, state, refs, _, e)
  local player = game.get_player(player_index)

  local action = msg.name
  if action == "init" then
    refs.titlebar_flow.drag_target = refs.window
    refs.window.force_auto_center()
    player.opened = refs.window
  elseif action == "close" then
    state.visible = false
    if player.opened == refs.window then
      player.opened = nil
    end
  elseif action == "open" then
    state.visible = true
  elseif action == "add_todo" then
    state.todos[#state.todos + 1] = {
      completed = false,
      text = state.new_todo_text
    }
    state.new_todo_text = ""
  elseif action == "toggle_todo_completed" then
    local todo = state.todos[msg.index]
    todo.completed = not todo.completed
  elseif action == "delete_todo" then
    table.remove(state.todos, msg.index)
  elseif action == "update_todo_text" then
    state.new_todo_text = e.element.text
  end
end

function component.view(state)
  return (
    {
      type = "frame",
      direction = "vertical",
      visible = state.visible,
      on_closed = "close",
      ref = "window",
      children = {
        {type = "flow", ref = "titlebar_flow", children = {
          {type = "label", style = "frame_title", caption = "Todo", ignored_by_interaction = true},
          {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
          {
            type = "sprite-button",
            style = "frame_action_button",
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black",
            on_click = "close"
          }
        }},
        {type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical", children = {
          {
            type = "textfield",
            text = state.new_todo_text,
            on_text_changed = "update_todo_text",
            on_confirmed = "add_todo"
          },
          {
            type = "flow",
            direction = "vertical",
            top_padding = 8,
            visible = #state.todos > 0,
            children = table.map(state.todos, function(todo, i)
              return (
                {type = "flow", vertical_align = "center", children = {
                  {
                    type = "checkbox",
                    state = todo.completed,
                    on_checked_state_changed = {name = "toggle_todo_completed", index = i},
                    caption = todo.text
                  },
                  {type = "empty-widget", style = "flib_horizontal_pusher"},
                  {
                    type = "sprite-button",
                    style = "tool_button_red",
                    sprite = "utility/trash",
                    on_click = {name = "delete_todo", index = i}
                  }
                }}
              )
            end)
          }
        }}
      }
    }
  )
end

return component