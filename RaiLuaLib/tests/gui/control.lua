local event = require('lualib.event')
local gui = require('lualib.gui')
local mod_gui = require('mod-gui')

gui.add_templates{
  pushers = {
    horizontal = {type='empty-widget', name='pusher', style={horizontally_stretchable=true}},
    vertical = {type='empty-widget', name='pusher', style={vertically_stretchable=true}}
  }
}
gui.add_handlers('demo', {
  auto_clear_checkbox = {
    on_gui_checked_state_changed = function(e) game.print(serpent.block(e)) end
  },
  cardinals_checkbox = {
    on_gui_checked_state_changed = function(e) game.print(serpent.block(e)) end
  },
  grid_type_switch = {
    on_gui_switch_state_changed = function(e) game.print(serpent.block(e)) end
  },
  divisor_slider = {
    on_gui_value_changed = function(e) game.print(serpent.block(e)) end
  },
  divisor_textfield = {
    on_gui_confirmed = function(e) game.print(serpent.block(e)) end,
    on_gui_text_changed = function(e) game.print(serpent.block(e)) end
  }
})

event.on_player_created(function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{type='button', name='gui_module_mod_gui_button', style=mod_gui.button_style, caption='Template'}
end)

event.on_gui_click(function(e)
  local player = game.get_player(e.player_index)
  local frame_flow = mod_gui.get_frame_flow(player)
  local window = frame_flow.demo_window
  if window then
    gui.destroy(window, 'demo', e.player_index)
  else
    local data = gui.create(frame_flow, 'demo', e.player_index,
      {type='frame', name='demo_window', style='dialog_frame', direction='vertical', children={
        -- checkboxes
        {type='flow', name='checkboxes_flow', direction='horizontal', children={
          {type='checkbox', name='autoclear', caption='Auto-clear', state=true, handlers='auto_clear_checkbox', save_as=true},
          {template='pushers.horizontal'},
          {type='checkbox', name='cardinals', caption='Cardinals only', state=true, handlers='cardinals_checkbox', save_as=true}
        }},
        -- grid type switch
        {type='flow', name='switch_flow', style={vertical_align='center'}, direction='horizontal', children={
          {type='label', name='label', caption='Grid type:'},
          {template='pushers.horizontal'},
          {type='switch', name='switch', left_label_caption='Increment', right_label_caption='Split', state='left', handlers='grid_type_switch', save_as=true}
        }},
        -- divisor label
        {type='flow', name='divisor_label_flow', style={horizontal_align='center', horizontally_stretchable=true}, children={
          {type='label', name='label', style='caption_label', caption='Number of tiles per subgrid', save_as='grid_type_label'},
        }},
        -- divisor slider and textfield
        {type='flow', name='divisor_flow', style={horizontal_spacing=8, vertical_align='center'}, direction='horizontal', children={
          {type='slider', name='slider', style={name='notched_slider', horizontally_stretchable=true}, minimum_value=4, maximum_value=12, value_step=1, value=5,
            discrete_slider=true, discrete_values=true, handlers='divisor_slider', save_as=true},
          {type='textfield', name='textfield', style={width=50, horizontal_align='center'}, numeric=true, lose_focus_on_confirm=true, text=5,
            handlers='divisor_textfield', save_as=true}
        }}
      }}
    )
    game.print(serpent.block(data))
  end
end, {gui_filters='gui_module_mod_gui_button'})