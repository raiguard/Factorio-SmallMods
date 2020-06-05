local styles = data.raw["gui-style"].default

styles.sandbox_listbox_style = {
  type = "list_box_style",
  parent = "list_box",
  width = 100,
  item_style = {
    type = "button_style",
    parent = "list_box_item",
    horizontal_align = "right"
  }
}