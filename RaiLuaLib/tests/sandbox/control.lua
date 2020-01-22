local mod_gui = require('mod-gui')

script.on_event(defines.events.on_player_created, function(e)
  local button_flow = mod_gui.get_button_flow(game.get_player(e.player_index))
  button_flow.add{type='button', name='8', style=mod_gui.button_style, caption='8'}
  button_flow.add{type='button', name='9', style=mod_gui.button_style, caption='9'}
  button_flow.add{type='button', name='10', style=mod_gui.button_style, caption='10'}
  button_flow.add{type='button', name='80', style=mod_gui.button_style, caption='80'}
  local window = mod_gui.get_frame_flow(game.get_player(e.player_index)).add{type='frame', name='listbox_frame', style='dialog_frame'}
  window.style.height = 150
  window.style.top_padding = 8
  -- listbox
  local listbox = window.add{type='list-box', name='listbox'}
  listbox.style.width = 70
  for i=1,100 do
    listbox.add_item(i, i)
  end
  -- scrollpane
  local scrollpane = window.add{type='scroll-pane', name='scrollpane', style='list_box_scroll_pane'}
  scrollpane.style.width = 70
  scrollpane.style.left_margin = 8
  for i=1,100 do
    local button = scrollpane.add{type='button', style='list_box_item', caption=i}
    button.style.top_margin = -4
    button.style.horizontally_stretchable = true
  end
  scrollpane.children[1].style.top_margin = 0
end)

script.on_event(defines.events.on_gui_click, function(e)
  local listbox_frame = mod_gui.get_frame_flow(game.get_player(e.player_index)).listbox_frame
  listbox_frame.listbox.scroll_to_item(tonumber(e.element.name))
  listbox_frame.scrollpane.scroll_to_element(listbox_frame.scrollpane.children[tonumber(e.element.name)])
end)