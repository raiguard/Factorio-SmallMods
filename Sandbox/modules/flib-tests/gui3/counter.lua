local gui = require("__flib__.gui-new")

local counter_gui = gui.root("counter")

function counter_gui.init()
  return {
    count = 0
  }
end

function counter_gui.update(state, msg)
  if msg == "increment" then
    state.count = state.count + 1
  elseif msg == "reset" then
    state.count = 0
  end
end

function counter_gui.view(state)
  return (
    {type = "flow", children = {
      {
        type = "button",
        style = "mod_gui_button",
        caption = "Reset",
        on_click = "reset"
      },
      {
        type = "button",
        style = "mod_gui_button",
        caption = "Count: "..state.count,
        on_click = "increment"
      }
    }}
  )
end

return counter_gui