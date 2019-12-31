-- to simplify things, we'll just assume that there's one player and that you're in singleplayer.

local function translate(e)
  game.get_player(1).request_translation{'item-name.iron-ore'}
  script.on_event(defines.events.on_tick, nil)
end

local function print_translation(e)
  game.print(e.result)
end

local function register_handlers(e)
  -- translate on the first tick
  script.on_event(defines.events.on_tick, translate)
  -- show translated strings
  script.on_event(defines.events.on_string_translated, print_translation)
end

script.on_init(register_handlers)

script.on_load(register_handlers)