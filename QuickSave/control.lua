script.on_event("quicksave", function(e)
  local player = game.get_player(e.player_index)
  if player.admin then
    game.auto_save("quick")
  else
    player.print{"quicksave-message.must-be-admin"}
  end
end)