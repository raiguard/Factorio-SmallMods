local event = require("__flib__.event")
local table = require("__flib__.table")

event.on_init(function()
  local breakpoint
  local arr = {10, 20, 30, 40, 50, 60, 70, 80, 90}

  local sliced = table.slice(arr, 3, 7) -- should be {30, 40, 50, 60, 70}
  local spliced = table.splice(arr, 1, 4) -- should be {10, 20, 30, 40}
end)