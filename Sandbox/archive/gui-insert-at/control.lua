local event = require("__flib__.event")
-- local gui = require("__flib__.gui")

local mod_gui = require("__core__.lualib.mod-gui")

-- event.on_init(function()
--   gui.init()
--   gui.build_lookup_tables()
-- end)

-- event.on_load(function()
--   gui.build_lookup_tables()
-- end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)

  local frame = mod_gui.get_frame_flow(player).add{type = "frame", direction = "vertical"}

  for i = 1, 4 do
    frame.add{type = "label", caption = i}
  end

  frame.add{type = "label", caption = "NEW", index = 2}

  local button_flow = mod_gui.get_button_flow(player)

  button_flow.add{
    type = "textfield",
    numeric = true,
    lose_focus_on_confirm = true,
    text = "1"
  }
  button_flow.add{
    type = "button",
    name = "insert",
    style = mod_gui.button_style,
    caption = "Insert"
  }
end)

event.on_gui_click(function(e)
  if e.element.name == "insert" then
    local player = game.get_player(e.player_index)
    local frame = mod_gui.get_frame_flow(player).children[1]
    local index = tonumber(e.element.parent.children[2].text)
    frame.add{
      type = "label",
      caption = index,
      index = 2
    }
  end
end)