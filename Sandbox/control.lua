local modules = require("modules")
for _,module in pairs(modules) do
  pcall(require, "modules."..module..".control")
end