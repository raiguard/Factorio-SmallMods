local modules = require("modules")
for _, module in pairs(modules) do
  pcall(require, module..".data-updates")
end