local gui = require("__flib__.gui")

local constants = require("constants")

local sensors = {}
for _, sensor_name in pairs(constants.sensors) do
  sensors[sensor_name] = require("scripts.sensor."..sensor_name)
end

local stats_gui = {}

function stats_gui.build(player, player_table)
  local single_line = player_table.settings.single_line

  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      style = "statsgui_frame",
      style_mods = {top_padding = single_line and 10 or 38, horizontally_stretchable = true},
      direction = single_line and "horizontal" or "vertical",
      ignored_by_interaction = true,
      save_as = "window",
      children = {
        {type = "empty-widget", style = "flib_horizontal_pusher"},
      }
    }
  })

  player_table.gui.stats = refs

  stats_gui.set_size(player, player_table)
  stats_gui.update(player, player_table)
end

function stats_gui.destroy(player_table)
  player_table.gui.stats.window.destroy()
  player_table.gui.stats = nil
end

function stats_gui.update(player, player_table)
  local refs = player_table.gui.stats
  local window = refs.window

  local i = 0
  for _, sensor in pairs(sensors) do
    i = i + 1
    local caption = sensor(player, player_table)
    local label = window.children[i + 1]
    if label then
      label.caption = caption
    else
      window.add{
        type = "label",
        style = "statsgui_label",
        caption = caption
      }
    end
  end
end

function stats_gui.set_size(player, player_table)
  local window = player_table.gui.stats.window

  local single_line = player_table.settings.single_line
  local additional_offset = single_line and 180 or 0

  window.style.width = ((player.display_resolution.width / player.display_scale) - 287 - additional_offset)
end

return stats_gui