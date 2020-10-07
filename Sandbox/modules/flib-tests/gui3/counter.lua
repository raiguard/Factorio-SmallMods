local gui = require("__flib__.gui3")

local counter = gui.new("counter")

function counter.init()
  return {
    count = 0
  }
end

function counter.update(state, msg)
  if msg == "increment" then
    state.count = state.count + 1
  elseif msg == "reset" then
    state.count = 0
  end
end

function counter.view(state)
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

return counter