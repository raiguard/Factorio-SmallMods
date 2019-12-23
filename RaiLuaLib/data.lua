local tests = require('tests')
for test,enabled in pairs(tests) do
  if enabled then
    require('tests/'..test..'/data')
  end
end

data:extend{
  {
    type = 'custom-input',
    name = 'debug-inspect-global',
    key_sequence = 'CONTROL + SHIFT + ENTER'
  }
}