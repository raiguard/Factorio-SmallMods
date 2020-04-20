-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROL SCRIPTING

-- dependencies
local event = require("__RaiLuaLib__.lualib.event")
local migration = require("__RaiLuaLib__.lualib.migration")
local translation = require("__RaiLuaLib__.lualib.translation")

-- locals
local string_gsub = string.gsub
local string_sub = string.sub

-- -----------------------------------------------------------------------------
-- DATA MANAGEMENT

local function build_prototype_data()
  local item_data = {}
  local translation_data = {}
  for name,prototype in pairs(game.item_prototypes) do
    item_data[name] = {localised_name=prototype.localised_name, hidden=prototype.has_flag("hidden")}
    translation_data[#translation_data+1] = {localised=prototype.localised_name, internal=prototype.name}
  end
  global.__lualib.translation.translation_data = translation_data
  global.item_data = item_data
end

local function setup_player(player, index)
  global.players[index] = {
    flags = {
      can_open_gui = false,
      translate_on_join = false,
      show_message_after_translation = false
    },
    gui = {},
    translations = nil,
    settings = nil
  }
end

local function update_player_settings(player, player_table)
  local settings = {}
  for name, t in pairs(player.mod_settings) do
    if string_sub(name, 1,4) == "qis-" then
      name = string_gsub(name, "qis%-", "")
      settings[string_gsub(name, "%-", "_")] = t.value
    end
  end
  player_table.settings = settings
end

local function refresh_player_data(player, player_table)
  -- TODO: destroy GUI(s)
  -- set flag
  player_table.flags.can_open_gui = false

  -- update settings
  update_player_settings(player, player_table)

  -- run translations
  player_table.translations = nil
  if player.connected then
    translation.start(player, "items", global.__lualib.translation.translation_data, {include_failed_translations=true})
  else
    player_table.flags.translate_on_join = true
  end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

event.on_init(function()
  global.players = {}
  build_prototype_data()
  for index, player in pairs(game.players) do
    setup_player(player, index)
    refresh_player_data(player, global.players[index])
  end
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  setup_player(player, e.player_index)
  refresh_player_data(player, global.players[e.player_index])
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.on_player_joined_game(function(e)
  local player_table = global.players[e.player_index]
  if player_table.flags.translate_on_join then
    translation.start(game.get_player(e.player_index), "items", global.__lualib.translation.translation_data, {include_failed_translations=true})
  end
end)

event.on_runtime_mod_setting_changed(function(e)
  if string_sub(e.setting, 1, 4) == "qis-" then
    for i, p in pairs(game.players) do
      update_player_settings(p, global.players[i])
    end
  end
end)

event.register(translation.finish_event, function(e)
  -- add translations to player table
  local player_table = global.players[e.player_index]
  player_table.translations = e.translations
  -- show message if needed
  if player_table.flags.show_message_after_translation then
    game.get_player(e.player_index).print{'qis-message.can-open-gui'}
  end
  -- update flags
  player_table.flags.can_open_gui = true
  player_table.flags.translate_on_join = false
  player_table.flags.show_message_after_translation = false
end)

event.register("qis-search", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if player_table.flags.can_open_gui then
    -- TODO: toggle GUI
  else
    player.print{"qis-message.cannot-open-gui"}
    player_table.flags.show_message_after_translation = true
  end
end)

-- -----------------------------------------------------------------------------
-- COMMANDS

commands.add_command("QuickItemSearch", " [parameter]\nrefresh-player-data - retranslate dictionaries and update settings",
  function(e)
    if e.parameter == "refresh-player-data" then
      refresh_player_data(game.get_player(e.player_index), global.players[e.player_index])
    end
  end
)

-- -----------------------------------------------------------------------------
-- MIGRATIONS

-- table of migration functions
local migrations = {}

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    -- update translation data
    build_prototype_data()
    -- refresh all player information
    for i, p in pairs(game.players) do
      refresh_player_data(p, global.players[i])
    end
  end
end)