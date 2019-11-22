local util = require('__core__/lualib/util')

function util.get_player(obj)
    if type(obj) == 'number' then return game.players[obj]
    else return game.players[obj.player_index] end
end

function util.player_table(obj)
    if type(obj) == 'number' then 
        return global.players[obj]
    else
        return obj.index and global.players[obj.index] or global.players[obj.player_index]
    end
end

util.constants = {
    quick_shots_path = 'ScreenshotPlus/Quick shots/',
    timelapse_path = 'ScreenshotPlus/Timelapse/',
    debug_path = 'ScreenshotPlus/Debug/'
}

return util