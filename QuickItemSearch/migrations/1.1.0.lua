if not global.players then return end

global.dictionaries = nil
global.__translation = {
  dictionary_count = 0,
  players = {}
}
for i,p in pairs(game.players) do
  global.players[i].flags.can_open_gui = false
end