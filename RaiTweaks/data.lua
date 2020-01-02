data:extend{
  {
    type = 'custom-input',
    name = 'rt-relocate-fluid',
    key_sequence = 'ALT + R'
  }
}

-- DEBUGGING TOOL
if mods['debugadapter'] then
  data:extend{
    {
      type = 'custom-input',
      name = 'DEBUG-INSPECT-GLOBAL',
      key_sequence = 'CONTROL + SHIFT + ENTER'
    }
  }
end