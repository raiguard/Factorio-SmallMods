-- GUI DEMO

local gui = require("__flib__.control.gui")
gui.register_events()

gui.add_templates{
  drag_handle = {type="empty-widget", style="draggable_space_header", style_mods={minimal_width=30, height=24,
    right_margin=4, horizontally_stretchable=true}},
  frame_action_button = {type="button", style="close_button", style_mods={width=20, height=20, top_margin=2}}
}

local function debug_print(e) game.print(serpent.block(e)) end

gui.add_handlers{
  titlebar_button = {
    on_gui_click = debug_print
  },
  slot_button = {
    on_gui_click = debug_print
  }
}

script.on_init(function()
  gui.init()
  gui.build_lookup_tables()
end)

script.on_load(function()
  gui.build_lookup_tables()
end)

local function create_gui(player)
  local elems = gui.build(player.gui.screen, {
    {type="frame", style="dialog_frame", direction="vertical", save_as="window", children={
      {type="flow", children={
        {type="label", style="frame_title", caption="Demo GUI"},
        {template="drag_handle", save_as="titlebar.drag_handle"},
        {template="frame_action_button", handlers="titlebar_button"},
        {template="frame_action_button", handlers="titlebar_button"},
        {template="frame_action_button", handlers="titlebar_button"}
      }},
      {type="frame", style="window_content_frame", style_mods={padding=12}, children={
        {type="frame", style="demo_dark_content_frame_in_light_frame", children={
          {type="scroll-pane", style="demo_slot_table_scroll_pane", style_mods={height=200}, children={
            {type="table", style="demo_slot_table", style_mods={width=400}, column_count=10, save_as="slot_table"}
          }}
        }}
      }}
    }}
  })

  elems.titlebar.drag_handle.drag_target = elems.window
  elems.window.force_auto_center()

  gui.update_filters("slot_button", player.index, {"demo_slot_button"}, "add")

  global.gui = elems
end

script.on_configuration_changed(function()
  create_gui(game.get_player(1))
end)

script.on_event(defines.events.on_player_created, function(e)
  create_gui(game.get_player(e.player_index))

end)

script.on_event(defines.events.on_player_main_inventory_changed, function(e)
  -- update GUI
  local table = global.gui.slot_table
  table.clear()
  local player = game.get_player(e.player_index)
  local i = 0
  for name, count in pairs(player.get_main_inventory().get_contents()) do
    i = i + 1
    table.add{type="sprite-button", name="demo_slot_button__"..i, style="CGUI_filter_slot_button", sprite="item/"..name,
    number=count}
  end
end)