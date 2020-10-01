local gui = require("__flib__.gui2")

local component = gui.component("counter")

-- returns the initial state
function component.init()
  -- for this example, we only need a single integer
  -- state _must_ be a table to allow in-place edits
  return {count = 0}
end

-- mutates the state in-place, so nothing is returned
function component.update(_, msg, state)
  if msg.name == "increment" then
    state.count = state.count + 1
  elseif msg.name == "reset" then
    state.count = 0
  end
end

-- returns the structure of the component based on the current state
function component.view(state)
  return (
    {type = "flow", children = {
      {
        type = "button",
        style = "mod_gui_button",
        caption = "Count: "..state.count,
        on_click = "increment"
      },
      {
        type = "button",
        style = "mod_gui_button",
        caption = "Reset",
        on_click = "reset"
      }
    }}
  )

end

return component
