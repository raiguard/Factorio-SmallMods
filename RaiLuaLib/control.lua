pcall(require,'__debugadapter__/debugadapter.lua')

local tests = require('tests')
for _,test in pairs(tests) do
  require('tests/'..test..'/control')
end

script.on_event('debug-inspect-global', function(e)
  local breakpoint -- put breakpoint here to inspect global at any time
end)