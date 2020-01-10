-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event handling

-- dependencies
local event = require('lualib/event')
local util = require('__core__/lualib/util')

-- locals
local table_deepcopy = table.deepcopy

-- PROTOTYPE TEMPLATE
local template = {
  {type='frame', name='window', style='dialog_frame', direction='vertical', children={
    {type='flow', name='titlebar', style='rll_titlebar_flow', direction='horizontal', children={
      {type='label', name='label', style='frame_title', caption='Fufucuddlypoops'},
      {type='empty-widget', name='pusher', style='rll_horizontal_pusher'},
      {type='sprite-button', name='close_button', style='frame_action_button', sprite='utility/close_white', hovered_sprite='utility/close_black',
        clicked_sprite='utility/close_black', mouse_button_filter={'left'}}
    }}
  }}
}

local function remove_key(t, key)
  local new_t = table_deepcopy(t)
  new_t[key] = nil
  return new_t
end

local gui = {}

-- no bueno...
local function recursive_load(parent, t)
  local elem = parent.add(remove_key(t, 'children'))
  local children = t.children
  if children then
    for i=1,#children do
      recursive_load(elem, children[i])
    end
  end
end

-- loads a GUI template and returns the elements
-- eventually this will register handlers as well
function gui.load_template(parent, name, template)
  local elems = {}

end