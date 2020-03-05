local tests = require('tests')
for _,test in pairs(tests) do
  require('tests/'..test..'/data')
end

data:extend{
  {
    type = 'custom-input',
    name = 'debug-inspect-global',
    key_sequence = 'CONTROL + SHIFT + ENTER'
  }
}