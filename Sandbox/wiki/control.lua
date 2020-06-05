local event = require("__flib__.event")
local gui = require("__flib__.gui")

local mod_gui = require("__core__.lualib.mod-gui")

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
      {type="frame", style="standalone_inner_frame_in_outer_frame", direction="vertical", children={
        {type="flow", children={
          {type="label", style="frame_title", caption="Standard"},
          {type="empty-widget", style="draggable_space_header", style_mods={height=24, horizontally_stretchable=true, right_margin=4}},
          {type="sprite-button", style="frame_action_button", sprite="utility/close_white"}
        }},
        {type="frame", style="inside_shallow_frame", children={
          {type="empty-widget", style_mods={width=300, height=150}}
        }}
      }},
      {type="frame", style="standalone_inner_frame_in_outer_frame", caption="Dialog", direction="vertical", children={
        {type="frame", style="inside_shallow_frame", children={
          {type="empty-widget", style_mods={width=300, height=150}}
        }},
        {type="flow", style="dialog_buttons_horizontal_flow", children={
          {type="button", style="back_button", caption="Back"},
          {type="empty-widget", style="draggable_space", style_mods={horizontally_stretchable=true, height=32}},
          {type="button", style="confirm_button", caption="Confirm"}
        }}
      }},
      {type="frame", style="standalone_inner_frame_in_outer_frame", direction="vertical", children={
        {type="flow", children={
          {type="label", style="frame_title", caption="Draggable dialog"},
          {type="empty-widget", style="draggable_space_header", style_mods={height=24, horizontally_stretchable=true}},
        }},
        {type="frame", style="inside_shallow_frame", children={
          {type="empty-widget", style_mods={width=300, height=150}}
        }},
        {type="flow", style="dialog_buttons_horizontal_flow", children={
          {type="button", style="back_button", caption="Back"},
          {type="empty-widget", style="draggable_space", style_mods={horizontally_stretchable=true, height=32}},
          {type="button", style="confirm_button", caption="Confirm"}
        }}
      }},
      {type="frame", style="standalone_inner_frame_in_outer_frame", direction="vertical", children={
        {type="flow", children={
          {type="label", style="frame_title", caption="Non-draggable dialog"},
          {type="empty-widget", style_mods={horizontally_stretchable=true}}
        }},
        {type="frame", style="inside_shallow_frame", children={
          {type="empty-widget", style_mods={width=300, height=150}}
        }},
        {type="flow", style="dialog_buttons_horizontal_flow", children={
          {type="button", style="back_button", caption="Back"},
          {type="empty-widget", style_mods={horizontally_stretchable=true}},
          {type="button", style="confirm_button", caption="Confirm"}
        }}
      }}
    }},
  })

  elems.window.force_auto_center()
end)