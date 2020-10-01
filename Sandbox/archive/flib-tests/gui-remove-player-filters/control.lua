local event = require("__flib__.event")
local gui = require("__flib__.gui")

gui.add_handlers{
  one = {
    one = {
      on_gui_checked_state_changed = function(e) return end,
      on_gui_click = function(e) return end
    },
    two = {
      on_gui_click = function(e) return end
    },
    three = {
      on_gui_click = function(e) return end
    },
    four = {
      on_gui_click = function(e) return end
    },
    five = {
      on_gui_click = function(e) return end
    },
  },
  two = {
    one = {
      on_gui_checked_state_changed = function(e) return end,
      on_gui_click = function(e) return end
    },
    two = {
      on_gui_click = function(e) return end
    },
    three = {
      on_gui_click = function(e) return end
    },
    four = {
      on_gui_click = function(e) return end
    },
    five = {
      on_gui_click = function(e) return end
    },
  }
}

event.on_init(function()
  gui.init()
  gui.build_lookup_tables()
end)

event.on_player_created(function(e)
  local screen = game.get_player(e.player_index).gui.screen
  gui.build(screen, {
    {type="button", caption="One", handlers="one"},
    {type="button", caption="Two", handlers="two"}
  })
  local breakpoint
  gui.remove_player_filters(e.player_index)
  local breakopint
end)