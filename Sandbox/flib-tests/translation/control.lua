local event = require("__flib__.event")
local translation = require("__flib__.translation")

local function add_requests(player_index)
  translation.add_requests(player_index, global.strings, true)
end

event.on_init(function()
  translation.init()
  global.strings = {}
  -- global.iterated = false
end)

event.on_tick(function(e)
  translation.iterate_batch(e)
end)

event.on_string_translated(function(e)
  local _, finished = translation.process_result(e)
  if finished then
    game.print("Player ["..e.player_index.."] has finished translations")
  end
end)

event.on_player_created(function(e)
  local strings = global.strings
  local i = 0
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
    for name, prototype in pairs(game[category.."_prototypes"]) do
      i = i + 1
      strings[i] = {dictionary=category, internal=name, localised=prototype.localised_name}
    end
  end
  add_requests(e.player_index)
end)