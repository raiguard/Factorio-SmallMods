-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI

local event = require("__RaiLuaLib__.lualib.event")
local gui = require("__RaiLuaLib__.lualib.gui")

local qis_gui = {}

function qis_gui.create(player, player_table)
  -- GUI prototyping
  local gui_data = gui.build(player.gui.screen, {
    {type="frame", style="dialog_frame", direction="vertical", save_as="window", children={
      {type="textfield", style="qis_main_textfield", clear_and_focus_on_right_click=true, save_as="main_textfield"},
      {type="frame", style="window_content_frame", style_mods={padding=12, top_margin=5}, children={
        {type="frame", style="qis_dark_content_frame_in_light_frame", save_as="results_frame", children={
          {type="scroll-pane", style="qis_results_slot_table_scroll_pane", save_as="results_scroll_pane", children={
            {type="table", style="qis_results_slot_table", column_count=5, save_as="results_table"}
          }}
        }}
      }}
    }}
  })

  gui_data.window.force_auto_center()
  -- for _=1,50 do
  --   gui_data.results_table.add{type="sprite-button", style="qis_slot_button_inventory", sprite="item/iron-ore", number=69420}
  -- end
  -- gui_data.results_frame.style.right_margin = -12
end

return qis_gui