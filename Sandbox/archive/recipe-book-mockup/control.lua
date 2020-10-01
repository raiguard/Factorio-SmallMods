local event = require("__flib__.event")
local gui = require("__flib__.gui")

gui.add_templates{
  frame_action_button = {type="sprite-button", style="rb_frame_action_button", mouse_button_filter={"left"}},
  pushers = {
    horizontal = {type="empty-widget", style_mods={horizontally_stretchable=true}},
    vertical = {type="empty-widget", style_mods={vertically_stretchable=true}}
  },
  listbox_with_label = function(name, caption)
    return
    {type="flow", direction="vertical", children={
      {type="label", style="rb_listbox_label", caption=caption, save_as=name.."_label"},
      {type="frame", style="rb_listbox_frame", save_as=name.."_frame", children={
        {type="list-box", style="rb_listbox", save_as=name.."_listbox"}
      }}
    }}
  end,
  quick_reference_scrollpane = function(name)
    return
    {type="flow", direction="vertical", children={
      {type="label", style="rb_listbox_label", save_as=name.."_label"},
      {type="frame", style="rb_icon_slot_table_frame", style_mods={maximal_height=160}, children={
        {type="scroll-pane", style="rb_icon_slot_table_scrollpane", children={
          {type="table", style="rb_icon_slot_table", style_mods={width=200}, column_count=5, save_as=name.."_table"}
        }}
      }}
    }}
  end
}

event.on_init(function()
  gui.init()
  gui.build_lookup_tables()
end)

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local elems = gui.build(player.gui.screen, {
    {type="frame", style="dialog_frame", direction="vertical", save_as="window", children={
      {type="flow", children={
        {type="label", style="frame_title", caption="Recipe Book"},
        {type="empty-widget", style="rb_drag_handle", save_as="drag_handle"},
        {template="frame_action_button", sprite="utility/close_white", hovered_sprite="utility/close_black", clicked_sprite="utility/close_black"}
      }},
      {type="flow", style_mods={horizontal_spacing=12}, children={
        -- search
        {type="frame", style="window_content_frame_packed", direction="vertical", children={
          {type="frame", style="subheader_frame", children={
            {type="label", style="subheader_caption_label", caption="Search by:"},
            {template="pushers.horizontal"},
            {type="drop-down", items={"crafter", "material", "recipe"}, selected_index=2}
          }},
          {type="textfield", style_mods={width=225, margin=8, bottom_margin=0}},
          {type="frame", style="rb_stretchy_listbox_frame", style_mods={margin=8, height=nil, vertically_stretchable=true}, children={
            {type="list-box", style="rb_listbox", items={"Foo", "bar", "cett", "lorem"}, selected_index=3}
          }}
        }},
        {type="frame", style="window_content_frame_packed", direction="vertical", children={
          {type="frame", style="subheader_frame", children={
            {type="sprite", style="rb_object_icon", sprite="recipe/oil-refinery"},
            {type="label", style="subheader_caption_label", style_mods={left_padding=0}, caption={"entity-name.oil-refinery"}},
            {template="pushers.horizontal", style_mods={horizontally_stretchable=true}}
          }},
          {type="flow", style_mods={padding=8, horizontal_spacing=8}, children={
            gui.templates.listbox_with_label("test1", "test1"),
            gui.templates.listbox_with_label("test2", "test2")
          }},
          {type="flow", style_mods={padding=8, horizontal_spacing=8}, children={
            gui.templates.listbox_with_label("test3", "test3"),
            gui.templates.listbox_with_label("test4", "test4")
          }}
        }}
      }}
    }}
  })

  elems.drag_handle.drag_target = elems.window
  elems.window.force_auto_center()
end)