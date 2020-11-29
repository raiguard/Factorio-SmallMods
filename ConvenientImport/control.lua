local function setup_player(player_index)
  local player = game.get_player(player_index)
  local frame = player.gui.relative.add{
    type = "frame",
    style = "quick_bar_window_frame",
    anchor = {
      gui = "blueprint-library-gui",
      position = defines.relative_gui_position.right,
    }
  }
  local pane = frame.add{
    type = "frame",
    style = "shortcut_bar_inner_panel"
  }
  local button = pane.add{
    type = "sprite-button",
    style = "shortcut_bar_button",
    sprite = "ci_import_string",
    tooltip = {"shortcut.import-string"}
  }
end

script.on_init(function()
  global.players = {}

  for i in pairs(game.players) do
    setup_player(i)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  setup_player(e.player_index)
end)