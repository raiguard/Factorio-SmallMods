local gui = require("__flib__.gui3")
local table = require("__flib__.table")

local TodoGui = gui.root("Todo")

function TodoGui:init()
  return {
    mode = "all",
    new_todo_text = "",
    next_id = 1,
    todos = {},
    visible = true
  }
end

function TodoGui:update(state, msg, e)
  local action = msg.action
  if action == "close" then
    state.visible = false
    -- if player.opened == refs.window then
    --   player.opened = nil
    -- end
  elseif action == "open" then
    state.visible = true
  elseif action == "add_todo" then
    state.todos[state.next_id] = {
      completed = false,
      text = state.new_todo_text
    }
    state.next_id = state.next_id + 1
    state.new_todo_text = ""
  elseif action == "toggle_todo_completed" then
    local todo = state.todos[msg.id]
    todo.completed = not todo.completed
  elseif action == "delete_todo" then
    state.todos[msg.id] = nil
  elseif action == "update_todo_text" then
    state.new_todo_text = e.element.text
  elseif action == "change_mode" then
    state.mode = msg.mode
  elseif action == "clear_completed" then
    state.todos = table.filter(state.todos, function(todo) return not todo.completed end)
  end
end

function TodoGui:view(state)
  -- flatten TODOs into an array
  local todo_elems = {}
  local i = 0
  for _, todo in pairs(state.todos) do
    if
      state.mode == "all"
      or (state.mode == "active" and todo.completed == false)
      or (state.mode == "completed" and todo.completed == true)
    then
      i = i + 1
      todo_elems[i] = (
        {type = "flow", vertical_align = "center", children = {
          {
            type = "checkbox",
            state = todo.completed,
            on_checked_state_changed = {action = "toggle_todo_completed", id = todo.id},
            caption = todo.text
          },
          {type = "empty-widget", style = "flib_horizontal_pusher"},
          {
            type = "sprite-button",
            style = "tool_button_red",
            sprite = "utility/trash",
            tooltip = "Delete",
            on_click = {action = "delete_todo", id = todo.id}
          }
        }}
      )
    end
  end

  return (
    {
      type = "frame",
      direction = "vertical",
      width = 500,
      visible = state.visible,
      on_closed = {action = "close"},
      children = {
        {type = "flow", children = {
          {type = "label", style = "frame_title", caption = "Todo", ignored_by_interaction = true},
          {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
          {
            type = "sprite-button",
            style = "frame_action_button",
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black",
            on_click = {action = "close"}
          }
        }},
        {type = "frame", style = "inside_shallow_frame", direction = "vertical", children = {
          {type = "flow", direction = "vertical", padding = 12, children = {
            {
              type = "textfield",
              horizontally_stretchable = true,
              width = 0,
              text = state.new_todo_text,
              on_text_changed = {action = "update_todo_text"},
              on_confirmed = {action = "add_todo"}
            },
            {
              type = "flow",
              direction = "vertical",
              top_padding = 8,
              visible = #state.todos > 0,
              children = todo_elems
            }
          }},
          {
            type = "frame",
            style = "subfooter_frame",
            left_padding = 12,
            visible = table_size(state.todos) > 0,
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
                  on_checked_state_changed = {action = "change_mode", mode = "all"},
                },
                {
                  type = "radiobutton",
                  caption = "Active",
                  state = state.mode == "active",
                  on_checked_state_changed = {action = "change_mode", mode = "active"},
                },
                {
                  type = "radiobutton",
                  caption = "Completed",
                  state = state.mode == "completed",
                  on_checked_state_changed = {action = "change_mode", mode = "completed"},
                },
                {type = "empty-widget", style = "flib_horizontal_pusher"},
                {
                  type = "button",
                  caption = "Clear completed",
                  on_click = {action = "clear_completed"},
                  enabled = table.for_each(state.todos, function(todo) return todo.completed end)
                }
              }}
            }
          }
        }}
      }
    }
  )
end

return TodoGui