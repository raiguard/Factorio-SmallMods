local queue = require("__LtnManager__.lib.queue")

local demo = {
  first = 3,
  last = 10,
  [3] = 3,
  [4] = 4,
  [5] = 5,
  [6] = 6,
  [7] = 7,
  [8] = 8,
  [9] = 9,
  [10] = 10
}

local to_remove = {
  [7] = true,
  [8] = true,
  [3] = true
}

local results = queue.pop_multi(demo, to_remove)

local breakpoint