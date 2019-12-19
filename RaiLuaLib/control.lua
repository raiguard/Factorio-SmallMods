local tests = require('tests')
for test,enabled in pairs(tests) do
  if enabled then
    require('tests/'..test..'/control')
  end
end