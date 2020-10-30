local gui = require("__flib__.gui-beta")

local todo_gui = {}

function todo_gui.build(player, player_table)
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = {"window"},
      actions = {
        on_closed = {gui = "todo", action = "close", foo = 12}
      },
      children = {
        {type = "flow", ref = {"titlebar_flow"}, children = {
          {type ="label", style = "frame_title", caption = "TodoMVC", ignored_by_interaction = true},
          {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
          {
            type = "sprite-button",
            style = "frame_action_button",
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black",
            mouse_button_filter = {"left"},
            actions = {
              on_click = {gui = "todo", action = "close"}
            }
          }
        }},
        {type = "frame", style = "inside_shallow_frame", direction = "vertical", children = {
          {
            type = "textfield",
            style_mods = {width = 500, margin = 12},
            ref = {"textfield"},
            actions = {
              on_text_changed = {gui = "todo", action = "update_text"}
            }
          },
          {type = "flow", direction = "vertical", ref = {"todos_flow"}},
          {type = "frame", style = "subfooter_frame", children = {
            {type = "flow", style_mods = {vertical_align = "center"}, ref = {"subfooter_flow"}, children = {
              {type = "label"},
              {type = "empty-widget", style = "flib_horizontal_pusher"},
              {
                type = "radiobutton",
                caption = "All",
                state = false,
                actions = {
                  on_checked_state_changed = {gui = "todo", action = "change_mode", mode = "all"},
                }
              },
              {
                type = "radiobutton",
                caption = "Active",
                state = false,
                actions = {
                  on_checked_state_changed = {gui = "todo", action = "change_mode", mode = "active"},
                }
              },
              {
                type = "radiobutton",
                caption = "Completed",
                state = false,
                actions = {
                  on_checked_state_changed = {gui = "todo", action = "change_mode", mode = "completed"},
                }
              },
              {type = "empty-widget", style = "flib_horizontal_pusher"},
              {
                type = "button",
                caption = "Clear completed",
                actions = {
                  on_click = {gui = "todo", action = "clear_completed"}
                }
              }
            }}
          }}
        }}
      }
    }
  })

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()

  player_table.todo = {
    state = {
      todos = {},
      text = "",
      visible = false
    },
    refs = refs
  }
end

function todo_gui.handle_action(e, action)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.todo

  if action == "open" then
    gui_data.refs.window.visible = true
    player.opened = gui_data.refs.window
  elseif action == "close" then
    gui_data.refs.window.visible = false
    if player.opened then
      player.opened = nil
    end
  end
end

return todo_gui