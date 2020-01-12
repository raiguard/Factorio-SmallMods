local event = require('lualib.event')
local gui = require('lualib.gui')
gui.load_templates{
  pushers = {
    horizontal = {type='empty-widget', name='pusher', style={horizontally_stretchable=true}},
    vertical = {type='empty-widget', name='pusher', style={vertically_stretchable=true}}
  },
  toolbar = {
    frame = {type='frame', name='toolbar', style={name='subheader_frame', vertical_align='center'}},
    label = {type='label', name='label', style='subheader_caption_label'}
  },
  buttons = {
    close = {type='sprite-button', name='close_button', style='close_button', sprite='utility/close_white', hovered_sprite='utility/close_black',
      clicked_sprite='utility/close_black', mouse_button_filter={'left'}},
    tool_grey = {type='sprite-button', style='tool_button'}
  },
  checkbox = {type='checkbox', name='checkkbox', caption='Checkbox'}
}
gui.load_handlers{
  auto_clear_checkbox = {
    on_checked_state_changed = function(e) game.print(serpent.block(e)) end
  }
}

event.on_player_created(function(e)
  local player = game.get_player(e.player_index).gui.screen
  local data = gui.create(player.gui.screen,
    {type='frame', name='window', style='dialog_frame', direction='vertical', children={
      {type='flow', name='checkboxes_flow', direction='horizontal', children={
        {template='checkbox', name='autoclear', caption='Auto-clear', state=true, handlers='auto_clear_checkbox'},
        {template='pushers.horizontal'},
        {template='checkbox', name='cardinals', caption='Cardinals only', state=true}
      }},
      {type='flow', name='switch_flow', style={vertical_align='center'}, direction='horizontal', children={
        {type='label', name='label', caption='Grid type:'},
        {template='pushers.horizontal'},
        {type='switch', name='switch', left_label_caption='Increment', right_label_caption='Split', state='left'}
      }},
      {type='flow', name='divisor_label_flow', style={horizontal_align='center', horizontally_stretchable=true}, children={
        {type='label', name='label', style='caption_label', caption='Number of tiles per subgrid'},
      }},
      {type='flow', name='divisor_flow', style={horizontal_spacing=8, vertical_align='center'}, direction='horizontal', children={
        {type='slider', name='slider', style={name='notched_slider', horizontally_stretchable=true}, minimum_value=4, maximum_value=12, value_step=1, value=5,
          discrete_slider=true, discrete_values=true},
        {type='textfield', name='textfield', style={width=50, horizontal_align='center'}, numeric=true, lose_focus_on_confirm=true, text=5}
      }}
    }},
    {player_index=e.player_index}
  )
end)