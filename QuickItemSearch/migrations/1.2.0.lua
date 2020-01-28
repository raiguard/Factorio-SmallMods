-- we must do this here instead of in on_configuration_changed so that the event module doesn't crash
global.__lualib = {
  event = table.deepcopy(global.conditional_event_registry),
  gui = {}
}
global.conditional_event_registry = nil