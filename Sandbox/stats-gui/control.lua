local function set_gui_location(player, window)
  local resolution = player.display_resolution
  local scale = player.display_scale
  window.location = {
    x = resolution.width - (450 * scale),
    y = (38 * scale)
  }
end

local function create_stats_gui(player)
  local window = player.gui.screen.add{type='frame', style='statsgui_empty_frame'}
  local label = window.add{type='label', name = 'statsgui_label', style='statsgui_label', caption='Evolution = 89%\nPlaytime = 22:43:11\nTime=15:50, day 1'}
  label.drag_target = window
  set_gui_location(player, window)
  return {window=window, label=label}
end

local function setup_player(index, player)
  global.players[index] = {
    flags = {},
    gui = {
      stats = create_stats_gui(player)
    },
    settings = {
      evolution = 'complex',
      time_played = true
    }
  }
end

script.on_init(function()
  global.players = {}
  for i,p in pairs(game.players) do
    setup_player(i, p)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  setup_player(e.player_index, game.get_player(e.player_index))
end)

script.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(e)
  set_gui_location(game.get_player(e.player_index), global.players[e.player_index].gui.stats.window)
end)

-- script.on_event(defines.events.on_gui_location_changed, function(e)
--   game.print(serpent.line(e.element.location))
-- end)