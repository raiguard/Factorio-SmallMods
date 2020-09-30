local gui = require("__flib__.gui2")
local table = require("__flib__.table")

local component = gui.component("todo")

function component.init()
  return {
    mode = "all",
    new_todo_text = "",
    next_id = 0,
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
    state.next_id = state.next_id + 1
    state.todos[#state.todos + 1] = {
      completed = false,
      text = state.new_todo_text,
      id = state.next_id
    }
    state.new_todo_text = ""
  elseif action == "toggle_todo_completed" then
    local find_id = msg.id
    local todo = state.todos[table.find_key(state.todos, function(todo) return todo.id == find_id end)]
    todo.completed = not todo.completed
  elseif action == "delete_todo" then
    local delete_id = msg.id
    table.remove(state.todos, table.find_key(state.todos, function(todo) return todo.id == delete_id end))
  elseif action == "update_todo_text" then
    state.new_todo_text = e.element.text
  elseif action == "change_mode" then
    state.mode = msg.mode
  elseif action == "clear_completed" then
    state.todos = table.filter(state.todos, function(todo) return not todo.completed end, true)
  end
end

function component.view(state)
  return (
    {
      type = "frame",
      direction = "vertical",
      width = 500,
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
        {type = "frame", style = "inside_shallow_frame", direction = "vertical", children = {
          {type = "flow", direction = "vertical", padding = 12, children = {
            {
              type = "textfield",
              text = state.new_todo_text,
              on_text_changed = "update_todo_text",
              on_confirmed = "add_todo",
              horizontally_stretchable = true,
              width = 0
            },
            {
              type = "flow",
              direction = "vertical",
              top_padding = 8,
              visible = #state.todos > 0,
              children = table.map(
                table.filter(state.todos, function(todo)
                  return (
                    state.mode == "all"
                    or (state.mode == "active" and todo.completed == false)
                    or (state.mode == "completed" and todo.completed == true)
                  )
                end, true),
                function(todo)
                  return (
                    {type = "flow", vertical_align = "center", children = {
                      {
                        type = "checkbox",
                        state = todo.completed,
                        on_checked_state_changed = {name = "toggle_todo_completed", id = todo.id},
                        caption = todo.text
                      },
                      {type = "empty-widget", style = "flib_horizontal_pusher"},
                      {
                        type = "sprite-button",
                        style = "tool_button_red",
                        sprite = "utility/trash",
                        tooltip = "Delete",
                        on_click = {name = "delete_todo", id = todo.id}
                      }
                    }}
                  )
                end
              )
            }
          }},
          {
            type = "frame",
            style = "subfooter_frame",
            left_padding = 12,
            visible = #state.todos > 0,
            children = {
              {type = "flow", vertical_align = "center", children = {
                {
                  type = "label",
                  caption = (
                    table.reduce(state.todos, function(acc, todo) return todo.completed and acc or acc + 1 end, 0)
                    .." items left"
                  )
                },
                {type = "empty-widget", style = "flib_horizontal_pusher"},
                {
                  type = "radiobutton",
                  caption = "All",
                  state = state.mode == "all",
                  on_checked_state_changed = {name = "change_mode", mode = "all"},
                },
                {
                  type = "radiobutton",
                  caption = "Active",
                  state = state.mode == "active",
                  on_checked_state_changed = {name = "change_mode", mode = "active"},
                },
                {
                  type = "radiobutton",
                  caption = "Completed",
                  state = state.mode == "completed",
                  on_checked_state_changed = {name = "change_mode", mode = "completed"},
                },
                {type = "empty-widget", style = "flib_horizontal_pusher"},
                {
                  type = "button",
                  caption = "Clear completed",
                  on_click = "clear_completed"
                }
              }}
            }
          }
        }}
      }
    }
  )
end

return component