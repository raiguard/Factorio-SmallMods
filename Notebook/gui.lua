-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTEBOOK GUI

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')

-- object
local self = {}
local handlers = {}

-- -----------------------------------------------------------------------------
-- UTILITIES



-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS



-- -----------------------------------------------------------------------------
-- OBJECT

-- create the GUI
function self.create(player, parent, visible)
  local elems = {}
  elems.window = parent.add{type='frame', name='nb_window', style='dialog_frame', direction='vertical'}

  elems.page_dropdown = elems.window.add{type='drop-down', name='nb_page_dropdown', items={'+ Add page'}}
  elems.page_dropdown.style.horizontally_stretchable = true

  elems.content_frame = elems.window.add{type='frame', name='nb_content_frame', style='nb_content_frame'}
  elems.content_scrollpane = elems.content_frame.add{type='scroll-pane', name='nb_content_scrollpane', style='nb_content_scrollpane'}

  -- TEST CONTENT
  local module_flow = elems.content_scrollpane.add{type='flow', name='nb_module_flow', direction='vertical'}
  module_flow.add{type='label', name='nb_module_label', style='caption_label', caption='Train colors'}
  local table = module_flow.add{type='table', name='nb_table', column_count = 2}
  table.add{type='label', name='nb_oil_label', caption='Crude Oil'}
  local value_flow = table.add{type='flow', name='nb_oil_flow', direction='horizontal'}
  value_flow.add{type='empty-widget', name='nb_pusher'}.style.horizontally_stretchable = true
  value_flow.add{type='textfield', name='nb_oil_textfield', text='255,255,255'}.style.width = 100
  elems.window.visible = visible or true
  return elems
end

-- destroy the GUI
function self.destroy(player, player_table)

end

-- set GUI visibility and register/deregister handlers
function self.set_visible(player, player_table, state)
  -- if state is nil, toggle instead of setting
end

-- create notebook button in the mod GUI
function self.create_mod_gui_button(player)
  return mod_gui.get_button_flow(player).add{type='button', name='toggle_notebook_button', style=mod_gui.button_style, caption='Notebook'}
end

return self