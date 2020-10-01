local math = require("__flib__.math")

local num = 3.14159265358

for _ = 1, 1000000 do
  math.round(num)
  math.round_to(num, 0)
  math.round_to(num, 5)
end