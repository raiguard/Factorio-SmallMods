script.on_init(function()
  global.next_index = 1
end)

script.on_event(defines.events.on_tick, function(e)
  if global.do_translations then
    local next_index = global.next_index
    for i=next_index, next_index + 9 do
      if i <= 1000 then
        local player = game.get_player(1)
        if player.connected then
          local string = {"translation-"..i}
          if player.request_translation(string) then
            log("REQUESTED: "..serpent.line(string))
          end
        end
      else
        global.do_translations = false
        break
      end
    end
    global.next_index = global.next_index + 10
  end
end)

script.on_event(defines.events.on_string_translated, function(e)
  log("RECEIVED: "..serpent.line(e.localised_string))
end)

script.on_event(defines.events.on_player_created, function(e)
  global.do_translations = true
end)