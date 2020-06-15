local event = require("__flib__.event")
local gui = require("__flib__.gui")

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  gui.build(player.gui.screen, {
    {type="frame", style="standalone_inner_frame_in_outer_frame", style_mods={top_padding=12}, direction="vertical", children={
      {type="frame", style="inside_shallow_frame", children={
        {type="flow", style_mods={padding=12, vertical_spacing=12, horizontal_align="center"}, direction="vertical", children={
          {type="table", style="slot_table", column_count=8, children={
            {type="sprite-button", style="flib_slot_default"},
            {type="sprite-button", style="flib_slot_red"},
            {type="sprite-button", style="flib_slot_yellow"},
            {type="sprite-button", style="flib_slot_green"},
            {type="sprite-button", style="flib_slot_cyan"},
            {type="sprite-button", style="flib_slot_blue"},
            {type="sprite-button", style="flib_slot_purple"},
            {type="sprite-button", style="flib_slot_pink"},
          }},
          {type="frame", style="slot_button_deep_frame", children={
            {type="table", style="slot_table", column_count=8, children={
              {type="sprite-button", style="flib_slot_button_default"},
              {type="sprite-button", style="flib_slot_button_red"},
              {type="sprite-button", style="flib_slot_button_yellow"},
              {type="sprite-button", style="flib_slot_button_green"},
              {type="sprite-button", style="flib_slot_button_cyan"},
              {type="sprite-button", style="flib_slot_button_blue"},
              {type="sprite-button", style="flib_slot_button_purple"},
              {type="sprite-button", style="flib_slot_button_pink"},
            }}
          }},
          {type="flow", style_mods={horizontal_spacing=4}, children={
            {type="sprite-button", style="flib_standalone_slot_button_default"},
            {type="sprite-button", style="flib_standalone_slot_button_red"},
            {type="sprite-button", style="flib_standalone_slot_button_yellow"},
            {type="sprite-button", style="flib_standalone_slot_button_green"},
            {type="sprite-button", style="flib_standalone_slot_button_cyan"},
            {type="sprite-button", style="flib_standalone_slot_button_blue"},
            {type="sprite-button", style="flib_standalone_slot_button_purple"},
            {type="sprite-button", style="flib_standalone_slot_button_pink"},
          }}
        }}
      }}
    }}
  })
end)