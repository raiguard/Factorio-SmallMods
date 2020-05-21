local event = require("__flib__.control.event")
local translation = require("__flib__.control.translation")

event.on_init(function()
  translation.init()
end)

event.on_tick(function(e)
  translation.iterate_batch(e)
end)

event.on_string_translated(function(e)
  local names, finished = translation.process_result(e)
  if finished then
    game.print("Player ["..e.player_index.."] has finished translations")
  end
end)

event.on_player_created(function(e)
  for _, category in ipairs
  {
    "achievement",
    "entity",
    "equipment",
    "fluid",
    "item",
    "recipe",
    "technology",
    "tile"
  }
  do
    local strings = {}
    local i = 0
    for name, prototype in pairs(game[category.."_prototypes"]) do
      i = i + 1
      strings[i] = {dictionary=category, internal=name, localised=prototype.localised_name}
    end
    translation.add_requests(e.player_index, strings, true)
  end
end)