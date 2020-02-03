local gui = require('lualib/gui-standalone')
local mod_gui = require('mod-gui')

gui.add_templates{
  pushers = {
    horizontal = {type='empty-widget', style={horizontally_stretchable=true}},
    vertical = {type='empty-widget', style={vertically_stretchable=true}}
  }
}

script.on_event(defines.events.on_player_created, function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{type='button', name='gui_module_mod_gui_button', style=mod_gui.button_style, caption='Template'}
end)

script.on_event(defines.events.on_gui_click, function(e)
  if e.element.name == 'gui_module_mod_gui_button' then
    local player = game.get_player(e.player_index)
    local frame_flow = mod_gui.get_frame_flow(player)
    local window = frame_flow.demo_window
    if window then
      window.destroy()
    else
      -- the template bit creates the static GUI structure
      local data = gui.create(frame_flow,
        {type='frame', name='demo_window', style='dialog_frame', direction='vertical', children={
          -- checkboxes
          {type='flow', direction='horizontal', children={
            {type='checkbox', caption='Auto-clear', state=true, save_as='autoclear_checkbox'},
            {template='pushers.horizontal'},
            {type='checkbox', caption='Cardinals only', state=true, save_as='cardinals_checkbox'}
          }},
          -- grid type switch
          {type='flow', style={vertical_align='center'}, direction='horizontal', children={
            {type='label', caption='Grid type:'},
            {template='pushers.horizontal'},
            {type='switch', left_label_caption='Increment', right_label_caption='Split', state='left', save_as='grid_type_switch'}
          }},
          -- divisor label
          {type='flow', style={horizontal_align='center', horizontally_stretchable=true}, children={
            {type='label', style='caption_label', caption='Number of tiles per subgrid', save_as='grid_type_label'},
          }},
          -- divisor slider and textfield
          {type='flow', style={horizontal_spacing=8, vertical_align='center'}, direction='horizontal', children={
            {type='slider', style={name='notched_slider', horizontally_stretchable=true}, minimum_value=4, maximum_value=12, value_step=1, value=5,
              discrete_slider=true, discrete_values=true, save_as='divisor_slider'},
            {type='textfield', style={width=50, horizontal_align='center'}, numeric=true, lose_focus_on_confirm=true, text=5, save_as='divisor_textfield'}
          }}
        }}
      )
      -- data will contain each element that you added a save_as key to
      -- here you would add dynamic content, such as a list of recipes, or add/remove content as appropriate to your GUI state
      -- you would also register your handlers here, or provide element names and add their handlers to the parent function
      game.print(serpent.block(data))
    end
  end
end)