local gui = require("__flib__.gui3")

local CounterGui = gui.root("Counter")

function CounterGui:init()
  return {
    count = 0
  }
end

function CounterGui:update(state, msg)
  if msg == "increment" then
    state.count = state.count + 1
  elseif msg == "reset" then
    state.count = 0
  end
end

function CounterGui:view(state)
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

return CounterGui