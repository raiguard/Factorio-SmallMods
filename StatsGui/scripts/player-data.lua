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

  stats_gui.build(player, global.players[player_index])
end

return player_data