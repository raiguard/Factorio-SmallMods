local event = require("__flib__.event")
local gui = require("__flib__.gui-beta")
local mod_gui = require("mod-gui")

local todo_gui = require("modules.flib-tests.gui-beta.todo")

event.on_init(function()
  global.players = {}
end)

event.on_player_created(function(e)
  -- create player table
  global.players[e.player_index] = {}
  local player_table = global.players[e.player_index]

  local player = game.get_player(e.player_index)

  -- CREATE GUIS

  gui.build(mod_gui.get_button_flow(player), {
    {
      type = "button",
      style = mod_gui.button_style,
      caption = "TodoMVC",
      actions = {
        on_click = {gui = "mod_gui_button", action = "toggle_todo"}
      }
    }
  })

  todo_gui.build(player, player_table)
end)

event.on_gui_click(function(e)
  local action = gui.get_action(e)
  if action then
    if action.gui == "mod_gui_button" then
      local player_table = global.players[e.player_index]
      if action.action == "toggle_todo" then
        local visible = player_table.todo.refs.window.visible
        if visible then
          todo_gui.handle_action(e, "close")
        else
          todo_gui.handle_action(e, "open")
        end
      end
    elseif action.gui == "todo" then
      todo_gui.handle_action(e, action.action)
    end
  end
end)

event.on_gui_closed(function(e)
  local action = gui.get_action(e)
  if action then
    if action.gui == "todo" then
      todo_gui.handle_action(e, action.action)
    end
  end
end)

