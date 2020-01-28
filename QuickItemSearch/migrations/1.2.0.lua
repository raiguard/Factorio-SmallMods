-- we must do this here instead of in on_configuration_changed so that the event module doesn't crash
if global.conditional_event_registry then
  global.__lualib = {
    event = table.deepcopy(global.conditional_event_registry),
    translation = table.deepcopy(global.__translation)
  }
  global.conditional_event_registry = nil
end