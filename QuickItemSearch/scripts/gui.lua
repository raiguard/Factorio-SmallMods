-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI

local event = require("__RaiLuaLib__.lualib.event")
local gui = require("__RaiLuaLib__.lualib.gui")

local qis_gui = {}

gui.templates:extend{
  logistic_request_setter = {type="flow", style_mods={vertical_align="center", horizontal_spacing=10}, children={
    {type="slider", style_mods={minimal_width=130, horizontally_stretchable=true}},
    {type="textfield", style_mods={width=60, horizontal_align="center"}, numerical=true, lose_focus_on_confirm=true}
  }}
}

gui.handlers:extend{
  search_textfield = {
    on_gui_click = function(e)

    end,
    on_gui_closed = function(e)
      
    end,
    on_gui_text_changed = function(e)

    end,
  },
  result_button = {id=defines.events.on_gui_click, handler=function(e)
    
  end, gui_filters="qis_result_button_", options={match_filter_strings=true}}
}

function qis_gui.create(player, player_table)
  -- GUI prototyping
  local gui_data = gui.build(player.gui.screen, {
    {type="frame", style="dialog_frame", direction="vertical", save_as="window", children={
      {type="textfield", style="qis_main_textfield", clear_and_focus_on_right_click=true, save_as="main_textfield"},
      {type="flow", children={
        {type="frame", style="qis_content_frame", style_mods={padding=12}, mods={visible=true}, children={
          {type="frame", style="qis_results_frame", save_as="results_frame", children={
            {type="scroll-pane", style="qis_results_scroll_pane", save_as="results_scroll_pane", children={
              {type="table", style="qis_results_table", column_count=5, save_as="results_table"}
            }}
          }}
        }},
        {type="frame", style="qis_content_frame", style_mods={padding=0}, direction="vertical", mods={visible=false}, children={
          {type="frame", style="subheader_frame", style_mods={height=30}, children={
            {type="label", style="caption_label", style_mods={left_margin=4}, caption="Logistics request"},
            {type="empty-widget", style_mods={horizontally_stretchable=true}},
            {type="sprite-button", style="green_button", style_mods={width=24, height=24, padding=0, top_margin=1}, sprite="utility/confirm_slot"}
          }},
          {type="flow", style_mods={top_padding=2, left_padding=10, right_padding=8}, direction="vertical", children={
            {template="logistic_request_setter"},
            {template="logistic_request_setter"}
          }}
        }}
      }}
    }}
  })

  event.enable("gui.result_button", player.index)

  gui_data.window.force_auto_center()
  for _=1,21 do
    gui_data.results_table.add{type="sprite-button", style="qis_slot_button_inventory", sprite="item/iron-ore", number=69420}
  end
end

return qis_gui