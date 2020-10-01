local event = require("__flib__.event")
local gui = require("__flib__.gui")

event.on_init(function()
  gui.init()
  gui.build_lookup_tables()
end)

event.on_load(function()
  gui.build_lookup_tables()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local elems = gui.build(player.gui.screen, {
    {type="frame", direction="vertical", save_as="window", children={
      {type="flow", save_as="titlebar_flow", children={
        {type="label", style="frame_title", caption="Mini-wiki", elem_mods={ignored_by_interaction=true}},
        {type="empty-widget", style="flib_titlebar_drag_handle", style_mods={minimal_width=30}, elem_mods={ignored_by_interaction=true}},
        {type="sprite-button", style="frame_action_button", sprite="utility/close_white"}
      }},
      {type="flow", style_mods={horizontal_spacing=12}, children={
        {type="frame", style="inside_deep_frame", direction="vertical", children={
          {type="frame", style="subheader_frame", children={
            {type="label", style="subheader_caption_label", caption="Mod:"},
            {type="empty-widget", style="flib_horizontal_pusher"},
            {type="drop-down", items={"Editor Extensions", "Factorio Library"}}
          }},
          {type="scroll-pane", style="flib_mw_pages_scroll_pane", children={
            {type="button", style="flib_mw_list_box_item", caption="Information", elem_mods={enabled=false}}
          }}
        }},
        {type="frame", style="inside_shallow_frame", direction="vertical", children={
          {type="frame", style="subheader_frame", children={
            {type="label", style="subheader_caption_label", caption="Information"},
            {type="empty-widget", style="flib_horizontal_pusher"},
            {type="sprite-button", style="tool_button", sprite="utility/search_icon"}
          }},
          {type="empty-widget", style_mods={width=300, height=300}}
        }}
      }}
    }}
  })
  elems.titlebar_flow.drag_target = elems.window
  elems.window.force_auto_center()
end)