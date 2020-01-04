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
  global.players[player.index] = {
    gui = {
      mod_gui_button = gui.create_mod_gui_button(player)
    },
    notebook = {
      ['Sample Page'] = {
        {name='Train Colors', type='table', table={
          {'[fluid=lubricant] Lubricant', '0,170,0'},
          {'[fluid=sulfuric-acid] Acid', '255,255,0'},
          {'[item=satellite] Rocket Supply', '255,0,100'},
          {'[item=power-armor-mk2] PAX Shuttle', '255,0,255'}
        }}
      }
    }
  }
  gui.create(player, global.players[player.index], mod_gui.get_frame_flow(player))
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
  gui.set_visible(game.get_player(e.player_index), global.players[e.player_index], false)
end, {gui_filters='toggle_notebook_button'})

event.register('nb-toggle-notebook', function(e)
  gui.set_visible(game.get_player(e.player_index), global.players[e.player_index])
end)

-- DEBUGGING
if __DebugAdapter then
  event.register('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end