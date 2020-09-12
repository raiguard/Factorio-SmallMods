local math = require("__flib__.math")

local num = 3.14159265358

local round = math.round(num)
local round_3 = math.round(num, 3)

local ceil = math.round(num, 0, "ceil")
local ceil_3 = math.round(num, 3, "ceil")

local floor = math.round(num, 0, "floor")
local floor_3 = math.round(num, 3, "floor")

local mean = math.mean{1, 2, 3, 4, 5, 100}

local breakpoint