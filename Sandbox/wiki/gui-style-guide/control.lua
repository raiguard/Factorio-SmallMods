local event = require("__flib__.event")
local gui = require("__flib__.gui")

local mod_gui = require("__core__.lualib.mod-gui")

gui.add_templates{
  tabbed_pane_dummy_content = {type="flow", direction="vertical", children={
    {type="frame", style="subheader_frame_under_tab_row", children={
      {type="label", style="subheader_caption_label", caption="Toolbar label"},
      {type="empty-widget", style_mods={horizontally_stretchable=true}},
      {type="sprite-button", style="tool_button_red", sprite="utility/trash"}
    }},
    {type="empty-widget", style_mods={height=50}}
  }}
}

gui.add_handlers{
  my_button = {
    on_gui_click = function(e)
      __DebugAdapter.print(e)
    end
  }
}

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
    {type="frame", style="invisible_frame", save_as="window", children={
      -- messing around
      -- {type="frame", style="quick_bar_window_frame", children={
      --   {type="frame", style="inside_deep_frame", children={
      --     {type="flow", style_mods={horizontal_spacing=2, padding=1}, children={
      --       {type="button", style=mod_gui.button_style, caption="My mod"},
      --       {type="sprite-button", style=mod_gui.button_style, sprite="utility/trash"}
      --     }}
      --   }}
      -- }}

      -- window types
      -- {type="frame", direction="vertical", children={
      --   {type="flow", children={
      --     {type="label", style="frame_title", caption="Standard"},
      --     {type="empty-widget", style="draggable_space_header", style_mods={height=24, horizontally_stretchable=true, right_margin=4}},
      --     {type="sprite-button", style="frame_action_button", sprite="utility/close_white"}
      --   }},
      --   {type="frame", style="inside_shallow_frame", children={
      --     {type="empty-widget", style_mods={width=300, height=150}}
      --   }}
      -- }},
      -- {type="frame", caption="Dialog", direction="vertical", children={
      --   {type="frame", style="inside_shallow_frame", children={
      --     {type="empty-widget", style_mods={width=300, height=150}}
      --   }},
      --   {type="flow", style="dialog_buttons_horizontal_flow", children={
      --     {type="button", style="back_button", caption="Back"},
      --     {type="empty-widget", style="draggable_space", style_mods={horizontally_stretchable=true, height=32}},
      --     {type="button", style="confirm_button", caption="Confirm"}
      --   }}
      -- }},
      -- {type="frame", style_mods={use_header_filler=false}, caption="mod_gui", direction="vertical", children={
      --   {type="frame", style="inside_shallow_frame", children={
      --     {type="empty-widget", style_mods={width=300, height=150}}
      --   }}
      -- }},
      -- {type="frame", direction="vertical", children={
      --   {type="label", style="caption_label", caption="Compact"}
      -- }},

      -- -- draggable vs. non-draggable
      -- {type="frame", direction="vertical", children={
      --   {type="flow", children={
      --     {type="label", style="frame_title", caption="Draggable dialog"},
      --     {type="empty-widget", style="draggable_space_header", style_mods={height=24, horizontally_stretchable=true}},
      --   }},
      --   {type="frame", style="inside_shallow_frame", children={
      --     {type="empty-widget", style_mods={width=300, height=150}}
      --   }},
      --   {type="flow", style="dialog_buttons_horizontal_flow", children={
      --     {type="button", style="back_button", caption="Back"},
      --     {type="empty-widget", style="draggable_space", style_mods={horizontally_stretchable=true, height=32}},
      --     {type="button", style="confirm_button", caption="Confirm"}
      --   }}
      -- }},
      -- {type="frame", direction="vertical", children={
      --   {type="flow", children={
      --     {type="label", style="frame_title", caption="Non-draggable dialog"},
      --     {type="empty-widget", style_mods={horizontally_stretchable=true}}
      --   }},
      --   {type="frame", style="inside_shallow_frame", children={
      --     {type="empty-widget", style_mods={width=300, height=150}}
      --   }},
      --   {type="flow", style="dialog_buttons_horizontal_flow", children={
      --     {type="button", style="back_button", caption="Back"},
      --     {type="empty-widget", style_mods={horizontally_stretchable=true}},
      --     {type="button", style="confirm_button", caption="Confirm"}
      --   }}
      -- }},

      -- -- toolbar examples
      -- {type="frame", direction="vertical", children={
      --   {type="flow", children={
      --     {type="label", style="frame_title", caption="Toolbar examples"},
      --     {type="empty-widget", style="draggable_space_header", style_mods={height=24, horizontally_stretchable=true, right_margin=4}},
      --     {type="sprite-button", style="frame_action_button", sprite="utility/close_white"}
      --   }},
      --   {type="frame", style="inside_deep_frame_for_tabs", children={
      --     {type="tabbed-pane", style="tabbed_pane_with_paddingless_content", children={
      --       {type="tab-and-content", tab={type="tab", caption="Foo"}, content={template="tabbed_pane_dummy_content"}},
      --       {type="tab-and-content", tab={type="tab", caption="Bar"}, content={template="tabbed_pane_dummy_content"}},
      --       {type="tab-and-content", tab={type="tab", caption="Baz"}, content={template="tabbed_pane_dummy_content"}}
      --     }}
      --   }}
      -- }}
    }}
  })

  -- elems.window.force_auto_center()
end)