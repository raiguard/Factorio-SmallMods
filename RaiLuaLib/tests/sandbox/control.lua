script.on_event(defines.events.on_player_joined_game, function(e)
  -- test two simultaneous translations
  local player = game.get_player(e.player_index)
  player.request_translation{'item-name.iron-ore'}
  player.request_translation{'item-name.iron-ore'}
  player.request_translation{'item-name.iron-ore'}
  player.request_translation{'item-name.iron-ore'}
  player.request_translation{'item-name.iron-ore'}
end)

script.on_event(defines.events.on_string_translated, function(e)
  log('translation!')
end)