local event = require("__flib__.event")
local gui = require("__flib__.gui")
local mod_gui = require("__core__.lualib.mod-gui")

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local frame_flow = mod_gui.get_frame_flow(player)
  gui.build(frame_flow, {
    {type="frame", style_mods={top_padding=12}, children={
      {type="frame", style="inside_shallow_frame_with_padding", direction="vertical", children={
        {type="table", style="bordered_table", column_count=1, children={
          {type="flow", style_mods={vertical_align="center"}, children={
            {type="label", style="caption_label", style_mods={width=100}, caption="[item=coal] 3600"},
            {type="sprite-button", style="tool_button", sprite="utility/export"}
          }},
          {type="flow", style_mods={vertical_align="center"}, children={
            {type="label", style="caption_label", style_mods={width=100}, caption="[item=coal] 3600"},
            {type="sprite-button", style="tool_button", sprite="utility/export"}
          }},
          {type="flow", style_mods={vertical_align="center"}, children={
            {type="label", style="caption_label", style_mods={width=100}, caption="[item=coal] 3600"},
            {type="sprite-button", style="tool_button", sprite="utility/export"}
          }}
        }}
      }}
    }}
  })
end)