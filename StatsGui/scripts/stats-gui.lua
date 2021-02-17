local constants = require("constants")

local sensors = {}
for sensor_name in pairs(constants.sensors) do
  sensors[sensor_name] = require("scripts.sensor."..sensor_name)
end

local stats_gui = {}

function stats_gui.build(player, player_table)
  local single_line = player_table.settings.single_line

  local window = player.gui.screen.add{
    type = "frame",
    style = "statsgui_frame",
    direction = single_line and "horizontal" or "vertical",
    ignored_by_interaction = true
  }

  player_table.stats_window = window

  stats_gui.set_width(player, player_table)
  stats_gui.update(player, player_table)
end

function stats_gui.destroy(player_table)
  player_table.stats_window.destroy()
  player_table.stats_window = nil
end

function stats_gui.update(player, player_table)

  local window = player_table.stats_window
  if not window then return end
  local children = window.children

  local settings = player_table.settings

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

function stats_gui.set_width(player, player_table)
  local window = player_table.stats_window
  if not window then return end
  window.style.width = (player.display_resolution.width / player.display_scale)
end

return stats_gui
