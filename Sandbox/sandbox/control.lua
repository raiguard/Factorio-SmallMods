local mod_gui = require("mod-gui")

script.on_event(defines.events.on_player_created, function(e)
  -- create the button to open/close the GUI
  local player = game.get_player(e.player_index)
  mod_gui.get_button_flow(player).add{type="button", name="test_button", style=mod_gui.button_style, caption="Test"}
end)

script.on_event(defines.events.on_gui_click, function(e)
  if e.element.name == "test_button" then
    local player = game.get_player(e.player_index)
    local frame_flow = mod_gui.get_frame_flow(player)
    if frame_flow.test_window and player.opened == frame_flow.test_window then
      -- if the window exists, set `opened` to `nil` to cause `on_gui_closed` to fire
      player.opened = nil
    else
      -- create the window
      local window = frame_flow.add{type="frame", name="test_window", style=mod_gui.frame_style, caption="Test window"}
      local spacer = window.add{type="frame", style="inside_shallow_frame"}
      spacer.style.height = 300
      spacer.style.width = 300
      -- set it as `opened`
      player.opened = window
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(e)
  if e.element and e.element.name == "test_window" then
    -- destroy the window
    local player = game.get_player(e.player_index)
    local window = mod_gui.get_frame_flow(player).test_window
    if window then window.destroy() end
  end
end)