if not global.players then return end

global.__translation.build_data = nil
global.__lualib = {
  event = table.deepcopy(global.conditional_event_registry),
  translation = table.deepcopy(global.__translation)
}
global.conditional_event_registry = nil
global.__translation = nil

for i,t in pairs(global.players) do
  t.search = nil
end