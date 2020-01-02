-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTEBOOK CONTROL SCRIPTING

 -- debug adapter
 pcall(require,'__debugadapter__/debugadapter.lua')

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')

-- locals


-- globals


-- modules
local gui = require('gui')

-- -----------------------------------------------------------------------------
-- UTILITIES

local function setup_player(player)
  local mod_gui_button = gui.create_mod_gui_button(player)
  global.players[player.index] = {
    gui = {
      mod_gui_button = mod_gui_button,
      notebook = gui.create(player, mod_gui.get_frame_flow(player))
    },
    notebook = {}
  }
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

event.on_init(function()
  global.players = {}
  for _,p in pairs(game.players) do
    setup_player(p)
  end
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.on_gui_click(function(e)
  gui.set_visible(game.get_player(e.player_index), global.players[e.player_index])
end, {gui_filters='toggle_notebook_button'})

-- DEBUGGING
if __DebugAdapter then
  event.register('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end