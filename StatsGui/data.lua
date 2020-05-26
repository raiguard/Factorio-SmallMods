local styles = data.raw['gui-style'].default

styles.statsgui_label = {
  type = 'label_style',
  font = 'default-game',
  font_color = default_font_color,
  -- hovered font color, borrowed from core/prototypes/style.lua
  hovered_font_color = {
    r = 0.5 * (1 + default_orange_color.r),
    g = 0.5 * (1 + default_orange_color.g),
    b = 0.5 * (1 + default_orange_color.b)
  },
  single_line = false
}