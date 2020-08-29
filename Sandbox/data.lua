local modules = require("modules")
for _, module in pairs(modules) do
  pcall(require, module..".data")
  pcall(require, module..".settings")
end