local modules = require('modules')
for _,module in pairs(modules) do
  require(module..'.control')
end