local gui = require("__flib__.gui3")

local tabs_gui = gui.root("tabs")

function tabs_gui.init()
  return {
    selected_tab = 1
  }
end

function tabs_gui.update(state, msg, e)
  if msg == "switch_tab" then
    state.selected_tab = e.element.selected_tab_index
  end
end

function tabs_gui.view(state)
  local tabs = {}
  for i = 1, 10 do
    -- TODO something bugs out with this logic in GUI3, inspect it!
    local type = state.selected_tab == i and "label" or "empty-widget"
    local caption = type == "label" and "IT CHANGED!" or nil
    tabs[i] = (
      {tab = {type = "tab", caption = tostring(i)}, content = (
        {type = type, name = tostring(i), height = 600, width = 600, caption = caption}
      )}
    )
  end

  return (
    {type = "frame", caption = "Tabs test", children = {
      {type = "frame", style = "inside_deep_frame_for_tabs", children = {
        {
          type = "tabbed-pane",
          selected_tab_index = state.selected_tab,
          on_selected_tab_changed = "switch_tab",
          tabs = tabs}
      }}
    }}
  )
end

return tabs_gui