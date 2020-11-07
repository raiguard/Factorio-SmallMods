local stats_gui = require("scripts.gui.stats")

local player_data = {}

function player_data.init(player_index, player)
  global.players[player_index] = {
    flags = {},
    gui = {},
    settings = {
      single_line = true
    }
  }
end

function player_data.refresh(player, player_table)
  if player_table.gui.stats then
    stats_gui.destroy(player_table)
  end

  stats_gui.build(player, player_table)
end

return player_data