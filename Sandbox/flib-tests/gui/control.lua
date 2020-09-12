local gui = require("__flib__.gui")
local mod_gui = require("mod-gui")

local function debug_print(e) game.get_player(e.player_index).print(serpent.block(e)) end

gui.add_templates{
  pushers = {
    horizontal = {type="empty-widget", style_mods={horizontally_stretchable=true}},
    vertical = {type="empty-widget", style_mods={vertically_stretchable=true}}
  }
}

gui.add_handlers{
  demo = {
    auto_clear_checkbox = {
      on_gui_checked_state_changed = debug_print
    },
    cardinals_checkbox = {
      on_gui_checked_state_changed = debug_print
    },
    grid_type_switch = {
      on_gui_switch_state_changed = debug_print
    },
    divisor_slider = {
      on_gui_value_changed = debug_print
    },
    divisor_textfield = {
      on_gui_confirmed = debug_print,
      on_gui_text_changed = debug_print,
      -- this should crash
      -- on_gui_invalid_event = debug_print
    }
  }
}

script.on_init(function()
  gui.init()
  gui.build_lookup_tables()
end)

script.on_load(function()
  gui.build_lookup_tables()
end)

script.on_event(defines.events.on_player_created, function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{
    type = "button",
    name = "gui_module_mod_gui_button",
    style = mod_gui.button_style,
    caption = "Template"
  }
end)

script.on_event(defines.events.on_gui_click, function(e)
  gui.dispatch_handlers(e)
  if e.element.name ~= "gui_module_mod_gui_button" then return end
  local player = game.get_player(e.player_index)
  local frame_flow = mod_gui.get_frame_flow(player)
  local window = frame_flow.demo_window
  if window then
    window.destroy()
  else
    -- Profiler.Start()
    local profiler = game.create_profiler()
    profiler.stop()
    for i=1,1000 do
      profiler.restart()
      local elems, filters = gui.build(frame_flow, {
        {type="frame", name="demo_window", direction="vertical", save_as="window", children={
          -- checkboxes
          {type="flow", name="checkboxes_flow", direction="horizontal", children={
            {type="checkbox", name="checkbox__autoclear", caption="Auto-clear", state=true, handlers="demo.auto_clear_checkbox", save_as="checkboxes.auto_clear"},
            {template="pushers.horizontal"},
            {type="checkbox", name="checkbox__cardinals", caption="Cardinals only", state=true, handlers="demo.cardinals_checkbox",
              save_as="checkboxes.cardinals.cardinals"}
          }},
          -- grid type switch
          {type="flow", name="switch_flow", style_mods={vertical_align="center"}, direction="horizontal", children={
            {type="label", name="label", caption="Grid type:"},
            {template="pushers.horizontal"},
            {type="switch", name="switch", left_label_caption="Increment", right_label_caption="Split", state="left", handlers="demo.grid_type_switch",
              save_as="grid_type_switch"}
          }},
          -- divisor label
          {type="flow", name="divisor_label_flow", style_mods={horizontal_align="center", horizontally_stretchable=true}, children={
            {type="label", name="label", style="caption_label", caption="Number of tiles per subgrid", save_as="grid_type_label"},
          }},
          -- divisor slider and textfield
          {type="flow", name="divisor_flow", style_mods={horizontal_spacing=8, vertical_align="center"}, direction="horizontal", children={
            {type="slider", name="slider", style="notched_slider", style_mods={horizontally_stretchable=true}, minimum_value=4, maximum_value=12,
              value_step=1, value=5, discrete_slider=true, discrete_values=true, handlers="demo.divisor_slider", save_as="divisor_slider"},
            {type="textfield", name="textfield", style_mods={width=50, horizontal_align="center"}, numeric=true, lose_focus_on_confirm=true, text=5,
              handlers="demo.divisor_textfield", save_as="divisor_textfield"}
          }}
        }}
      })
      profiler.stop()
      -- reset
      if i ~= 1000 then
        for id, t in pairs(filters) do
          gui.update_filters(id, player.index, t, "remove")
        end
        elems.window.destroy()
      end
    end
    profiler.divide(1000)
    game.print(profiler)
    -- Profiler.Stop()
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(e)
  gui.dispatch_handlers(e)
end)