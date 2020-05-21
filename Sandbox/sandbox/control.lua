local event = require("__flib__.control.event")

event.on_init(function()
  local handler = event.get_handler(defines.events.on_gui_click)
  local breakpoint
end)