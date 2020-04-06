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

local function register_handlers(player_index)
  for cn,t in pairs(handlers) do
    event.register(t[1], t[2], {name=cn, player_index=player_index, gui_filters=t[3]})
  end
end

local function deregister_handlers(player_index)
  for cn,t in pairs(handlers) do
    event.deregister(t[1], t[2], {name=cn, player_index=player_index})
  end
end

local function populate_page_dropdown(player_table, set_on_name, player_index)
  local gui_data = player_table.gui.notebook
  local notebook = player_table.notebook
  -- convert notebook pages into an array
  local sorted_names = {}
  for n,t in pairs(notebook) do
    sorted_names[#sorted_names+1] = n
  end
  table.sort(sorted_names)
  sorted_names[#sorted_names+1] = {'nb-gui.add-page'}
  -- add to dropdown
  gui_data.page_dropdown.items = sorted_names
  -- set selected index
  if set_on_name then
    -- find what index the given string is at and set it
    for i=1,#sorted_names do
      if sorted_names[i] == set_on_name then
        gui_data.page_dropdown.selected_index = i
        handlers.page_selection_changed[2]{player_index=player_index, element=gui_data.page_dropdown}
        break
      end
    end
  end
end

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

handlers.page_selection_changed = {
  defines.events.on_gui_selection_state_changed,
  function(e)
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    local gui_data = player_table.gui.notebook
    local element = e.element
    if element.selected_index == #element.items then
      element.parent.visible = false
      element.parent.parent.children[2].visible = true
      gui_data.name_textfield.focus()
    else
      local notebook = player_table.notebook[gui_data.page_dropdown.items[gui_data.page_dropdown.selected_index]]
      local pane = gui_data.content_scrollpane
      pane.clear()
      if gui_data.state == 'view' then
        -- populate scrollpane
        if #notebook == 0 then
          -- show default text
          pane.add{type='label', name='nb_no_content_label', style='nb_no_content_label', caption={'nb-gui.no-content'}}
        else
          for i=1,#notebook do
            local section = notebook[i]
            local section_flow = pane.add{type='flow', name='fe_section_flow_'..i, direction='vertical'}
            -- section label
            if not section.hide_name then
              section_flow.add{type='label', name='fe_section_name', style='caption_label', caption=section.name}
            end
            -- section content
            if section.type == 'table' then
              local table = section_flow.add{type='table', name='fe_section_table', column_count=2}
              for ti=1,#section.table do
                local data = section.table[ti]
                table.add{type='label', name='fe_label_'..ti, caption=data[1]}.style.font = 'default-semibold'
                table.add{type='label', name='fe_value_'..ti, style='nb_multiline_label', caption=data[2]}
              end
            elseif section.type == 'textbox' then

            elseif section.type == 'list' then

            elseif section.type == 'reminders' then

            end
          end
        end
      elseif gui_data.state == 'edit' then

      end
    end
  end,
  'nb_page_dropdown'
}

-- handlers.edit_button_clicked = {
--   defines.events.on_gui_click,
--   function(e)
--     game.print(serpent.block(e))
--   end,
--   'nb_edit_mode_button'
-- }

handlers.new_page_cancel_button_clicked = {
  defines.events.on_gui_click,
  function(e)
    e.element.parent.visible = false
    e.element.parent.parent.children[1].visible = true
    e.element.parent.children[2].text = ''
  end,
  'nb_new_page_cancel_button'
}

handlers.new_page_name_textfield_confirmed = {
  defines.events.on_gui_confirmed,
  function(e)
    local player_table = global.players[e.player_index]
    local gui_data = player_table.gui.notebook
    local notebook = player_table.notebook
    local element = e.element
    if notebook[element.text] then
      game.get_player(e.player_index).print{'nb-chat-message.page-already-exists'}
      element.select_all()
    else
      -- create page
      notebook[element.text] = {}
      -- update elements
      populate_page_dropdown(player_table, element.text, e.player_index)
      element.parent.visible = false
      element.parent.parent.children[1].visible = true
      element.text = ''
    end
  end,
  'nb_new_page_name_textfield'
}

-- -----------------------------------------------------------------------------
-- OBJECT

-- create the GUI
function self.create(player, player_table, parent)
  local gui_data = {}
  gui_data.window = parent.add{type='frame', name='nb_window', style='dialog_frame', direction='vertical'}
  gui_data.window.visible = false

  -- UPPER FLOW
  local upper_flow = gui_data.window.add{type='flow', name='nb_upper_flow', direction='horizontal'}
  -- dropdown
  local dropdown_flow = upper_flow.add{type='flow', name='nb_dropdown_flow', direction='horizontal'}
  gui_data.page_dropdown = dropdown_flow.add{type='drop-down', name='nb_page_dropdown'}
  gui_data.page_dropdown.style.horizontally_stretchable = true
  -- new page
  local new_page_flow = upper_flow.add{type='flow', name='nb_new_page_flow', direction='horizontal'}
  new_page_flow.visible = false
  new_page_flow.add{type='sprite-button', name='nb_new_page_cancel_button', style='red_icon_button', sprite='utility/reset'}
  gui_data.name_textfield = new_page_flow.add{type='textfield', name='nb_new_page_name_textfield', style='nb_new_page_textfield'}
  -- gui_data.edit_button = upper_flow.add{type='sprite-button', name='nb_edit_mode_button', style='tool_button', sprite='nb_edit',
  --   tooltip={'nb-gui.toggle-edit-mode'}}

  gui_data.content_frame = gui_data.window.add{type='frame', name='nb_content_frame', style='nb_content_frame'}
  gui_data.content_scrollpane = gui_data.content_frame.add{type='scroll-pane', name='nb_content_scrollpane', style='nb_content_scrollpane',
    horizontal_scroll_policy='never'}

  gui_data.state = 'view'
  player_table.gui.notebook = gui_data
  populate_page_dropdown(player_table)
  register_handlers(player.index)
end

-- destroy the GUI
function self.destroy(player, player_table)
  deregister_handlers(player.index)
end

-- set GUI visibility and register/deregister handlers
function self.set_visible(player, player_table, state)
  local gui_data = player_table.gui.notebook
  local to_state = (state ~= nil) and state or not gui_data.window.visible
  gui_data.window.visible = to_state
  if to_state == true then
    register_handlers(player.index)
  else
    deregister_handlers(player.index)
  end
end

-- create notebook button in the mod GUI
function self.create_mod_gui_button(player)
  return mod_gui.get_button_flow(player).add{type='button', name='toggle_notebook_button', style=mod_gui.button_style, caption='Notebook'}
end

return self