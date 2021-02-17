local gui = require("__flib__.gui-beta")

local constants = require("constants")

local sensors = {}
for sensor_name in pairs(constants.sensors) do
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
      ref = {"window"}
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
  local settings = player_table.settings

  local refs = player_table.gui.stats
  local window = refs.window
  local children = window.children

  local i = 0
  for sensor_name, sensor in pairs(sensors) do
    if settings["show_"..sensor_name] then
      local caption = sensor(player, player_table)
      if caption then
        i = i + 1
        local label = children[i]
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
  end
  -- remove extra children
  for j = i + 1, #children do
    children[j].destroy()
  end
end

function stats_gui.set_size(player, player_table)
  local window = player_table.gui.stats.window

  local single_line = player_table.settings.single_line
  local additional_offset = single_line and 180 or 0

  window.style.width = ((player.display_resolution.width / player.display_scale) - 287 - additional_offset)
end

return stats_gui
