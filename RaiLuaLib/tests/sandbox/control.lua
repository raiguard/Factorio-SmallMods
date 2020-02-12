local mod_gui = require('mod-gui')

script.on_event(defines.events.on_player_created, function(e)
  local player = game.get_player(e.player_index)
  local button_flow = mod_gui.get_button_flow(player)
  button_flow.add{type='textfield', name='textfield'}.style.width = 750
  button_flow.add{type='button', name='encode_button', style=mod_gui.button_style, caption='Encode'}
  button_flow.add{type='button', name='decode_button', style=mod_gui.button_style, caption='Decode'}
end)

script.on_event(defines.events.on_gui_click, function(e)
  local textfield = mod_gui.get_button_flow(game.get_player(e.player_index)).textfield
  if e.element.name == 'encode_button' then
    textfield.text = tostring(game.encode_string(textfield.text))
  elseif e.element.name == 'decode_button' then
    textfield.text = tostring(game.decode_string(textfield.text))
  end
end)