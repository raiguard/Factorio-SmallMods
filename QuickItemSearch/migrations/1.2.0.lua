require('__core__/lualib/util')

-- we must do this here since the event handler needs these changes before it can run on_configuration_changed
if global.conditional_event_registry then
  local data = table.deepcopy(global.conditional_event_registry)
  if global.__lualib then
    global.__lualib.event = data
  else
    global.__lualib = {event=data}
  end
  global.conditional_event_registry = nil
end