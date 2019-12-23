script.on_event(defines.events.on_player_joined_game, function(e)
    global.player = game.get_player(e.player_index)
    global.request_translation = global.player.request_translation
end)

script.on_event(defines.events.on_tick, function(e)
    global.request_translation{'item-name.iron-ore'}
end)