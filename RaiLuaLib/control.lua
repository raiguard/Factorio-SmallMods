pcall(require,'__debugadapter__/debugadapter.lua')

local tests = require('tests')
for _,test in pairs(tests) do
  require('tests/'..test..'/control')
end