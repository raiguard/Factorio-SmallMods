pcall(require,'__debugadapter__/debugadapter.lua')

local event = require('lualib/event')

local tests = require('tests')
for _,test in pairs(tests) do
  require('tests/'..test..'/control')
end

script.on_event('debug-inspect-global', function(e)
  local registry = event.get_registry()
  local breakpoint -- put breakpoint here to inspect global at any time
end)