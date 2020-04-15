-- reposition the GUI
local function set_gui_location(player, window)
  local resolution = player.display_resolution
  local scale = player.display_scale
  window.location = {
    x = resolution.width - (450 * scale),
    y = (38 * scale)
  }
end

local function create_stats_gui(player)
  local window = player.gui.screen.add{type="frame", style="statsgui_empty_frame"}
  local label = window.add{type="label", name="statsgui_main_label", style="statsgui_label"}
  set_gui_location(player, window)
  return {window=window, label=label}
end

local function setup_player(index, player)
  global.players[index] = {
    flags = {},
    gui = {
      stats = create_stats_gui(player)
    },
    settings = {
      evolution = true,
      evolution_decimals = 2,
      playtime = "on",
      time = "complex",
    }
  }
end

-- convert a number of ticks into runtime
-- always shows minutes and seconds, hours is optional
local function ticks_to_time(ticks)
  local seconds = math.floor(ticks / 60)
  local hours = string.format("%01.f", math.floor(seconds/3600));
  if tonumber(hours) > 0 then
    local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  else
    local mins = math.floor(seconds/60);
    local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return mins..":"..secs
  end
end

local function update_stats()
  local evo_factor = game.forces.enemy.evolution_factor * 100
  local playtime = ticks_to_time(game.tick)
  local days = math.floor(1 + ((game.tick + 12500) / 25000))
  for i,t in pairs(global.players) do
    local player = game.get_player(i)
    local daytime = player.surface.daytime + 0.5
    local daytime_minutes = math.floor(daytime * 24 * 60)
    local daytime_hours = math.floor(daytime_minutes / 60)
    daytime_minutes = daytime_minutes - (daytime_minutes % 15)
    local label = t.gui.stats.label
    local settings = t.settings
    local caption = {""}


    if settings.evolution then
      caption[#caption+1] = {"", {"statsgui.evolution"}, string.format(" = %."..settings.evolution_decimals.."f", evo_factor).."%\n"}
    end
    if settings.playtime == "on" then
      caption[#caption+1] = {"", {"statsgui.playtime"}, " = "..playtime.."\n"}
    end
    if settings.time ~= "off" then
      local c = {"", {"statsgui.time"}, " = "..string.format("%d:%02d", daytime_hours, daytime_minutes % 60),}
      if settings.time == "complex" then
        c[#c+1] = {"", ", ", {"statsgui.day"}, " "..days}
      end
      c[#c+1] = "\n"
      caption[#caption+1] = c
    end
    label.caption = caption
  end
end

script.on_init(function()
  global.players = {}
  for i,p in pairs(game.players) do
    setup_player(i, p)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  setup_player(e.player_index, game.get_player(e.player_index))
end)

script.on_event(defines.events.on_player_removed, function(e)
  global.players[e.player_index] = nil
end)

-- update the GUI location whenever screen properties change
script.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(e)
  set_gui_location(game.get_player(e.player_index), global.players[e.player_index].gui.stats.window)
end)

-- update info once per second
script.on_nth_tick(60, update_stats)