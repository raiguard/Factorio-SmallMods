local event = require('lualib/event')
local gui = require('lualib/gui')

local plus_button_style = {name='rll_row_slot_button_light_grey', padding=4}

local column_widths = {
  recipe = 41,
  percent = 55,
  machine = 52,
  modules = 68,
  beacons = 86,
  energy = 54,
  products = 54,
  byproducts = 69,
  ingredients = 356
}

local column_alignments = {
  recipe = 'center',
  percent = 'center',
  machine = 'center',
  modules = 'center',
  beacons = 'center',
  energy='center',
  products = 'left',
  byproducts = 'left',
  ingredients = 'left'
}

gui.add_templates{
  beacons = function(data)
    local children
    if not data.modules then
      children = {{type='sprite-button', style=plus_button_style, sprite='utility/add'}}
    else
      children = {
        {type='sprite-button', style='rll_row_slot_button_'..(data.modules.style or 'dark_grey'), sprite='item/'..data.modules.name,
          number=data.modules.number},
        {type='sprite', sprite='quantity-multiplier'},
        {type='sprite-button', style='rll_row_slot_button_'..(data.beacons.style or 'dark_grey'), sprite='entity/'..data.beacons.name,
          number=data.beacons.number}
      }
    end
    return {type='flow', style={vertical_align='center', horizontal_align=column_alignments.beacons, width=column_widths.beacons}, direction='horizontal',
      children=children}
  end,
  items = function(data, column)
    local children = {}
    if #data == 0 and column == 'modules' then
      children = {{type='sprite-button', style=plus_button_style, sprite='utility/add'}}
    else
      for i=1,#data do
        local t = data[i]
        children[i] = {type='sprite-button', style='rll_row_slot_button_'..(t.style or 'dark_grey'), sprite='item/'..t.name, number=t.number}
      end
    end
    return {type='flow', style={vertical_align='center', horizontal_align=column_alignments[column], width=column_widths[column]}, direction='horizontal',
      children=children}
  end
}
-- #region
local table_rows = {
  {
    recipe = {name='production-science-pack', style='green'},
    percent = 100,
    machine = {name='assembling-machine-3', number=3},
    modules = {{name='productivity-module-3', number=4}},
    beacons = {modules={name='speed-module-3', number=2}, beacons={name='beacon', number=8}},
    energy = '17.4 MW',
    products = {{name='production-science-pack', number=180}},
    byproducts = {},
    ingredients = {
      {name='stone', number=642, style='green'},
      {name='steel-plate', number=1000, style='green'},
      {name='advanced-circuit', number=428, style='green'},
      {name='stone-brick', number=428, style='green'},
      {name='iron-plate', number=321, style='red'},
      {name='electronic-circuit', number=214, style='green'}
    }
  },
  {
    recipe = {name='advanced-circuit'},
    percent = 100,
    machine = {name='assembling-machine-3', number=6},
    modules = {{name='productivity-module-3', number=4}},
    beacons = {modules={name='speed-module-3', number=2}, beacons={name='beacon', number=8}},
    energy = '17.4 MW',
    products = {{name='advanced-circuit', number=428}},
    byproducts = {},
    ingredients = {
      {name='plastic-bar', number=612, style='red'},
      {name='copper-cable', number=1200, style='green'},
      {name='electronic-circuit', number=612, style='green'}
    }
  },
  {
    recipe = {name='electronic-circuit'},
    percent = 100,
    machine = {name='assembling-machine-2', number=9},
    modules = {},
    beacons = {},
    energy = '1.38 MW',
    products = {{name='electronic-circuit', number='826'}},
    byproducts = {},
    ingredients = {
      {name='iron-plate', number=826, style='red'},
      {name='copper-cable', number=2400, style='green'}
    }
  },
  {
    recipe = {name='copper-cable'},
    percent = 100,
    machine = {name='assembling-machine-2', number=21},
    modules = {},
    beacons = {},
    energy = '3.09 MW',
    products = {{name='copper-cable', number=3700}},
    byproducts = {},
    ingredients = {{name='copper-plate', number=1800, style='red'}}
  },
  {
    recipe = {name='steel-plate'},
    percent = 100,
    machine = {name='electric-furnace', number='26'},
    modules = {{name='productivity-module-2', number=2}},
    beacons = {modules={name='speed-module-3', number=2}, beacons={name='beacon', number=8}},
    energy = '59 MW',
    products = {{name='steel-plate', number=1000}},
    byproducts = {},
    ingredients = {{name='iron-plate', number=4400, style='red'}}
  },
  {
    recipe = {name='stone-brick'},
    percent = 100,
    machine = {name='electric-furnace', number=12},
    modules = {},
    beacons = {},
    energy = '2.06 MW',
    products = {{name='stone-brick', number=428}},
    byproducts = {},
    ingredients = {{name='stone', number=857, style='green'}}
  },
  {
    recipe = {name='stone'},
    percent = 100,
    machine = {name='electric-mining-drill', number=27},
    modules = {{name='speed-module-2', number=2}, {name='productivity-module-2', number=1}},
    beacons = {},
    energy = '6.63 MW',
    products = {{name='stone', number=1500}},
    byproducts = {},
    ingredients = {{name='stone', number=1100}}
  }
}

event.on_player_joined_game(function(e)
  local player = game.get_player(e.player_index)
  local gui_data = gui.create(player.gui.screen, 'mockup', e.player_index,
    {type='frame', style='dialog_frame', direction='vertical', save_as='window', children={
      -- titlebar
      {type='flow', style={vertical_align='center', top_margin=-2}, children={
        {type='label', style='frame_title', caption='Factory Planner'},
        {type='empty-widget', style={name='draggable_space_header', height=24, right_margin=6, horizontally_stretchable=true}, save_as='drag_handle'},
        {type='sprite-button', style='close_button', sprite='utility/close_white', hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
      }},
      {type='flow', style={horizontal_spacing=12}, direction='horizontal', children={
        -- subfactory listbox
        {type='frame', style={name='inside_deep_frame', vertically_stretchable=true}, direction='vertical', children={
          {type='frame', style='subheader_frame', direction='horizontal', children={
            {type='empty-widget', style={horizontally_stretchable=true}},
            {type='sprite-button', style={name='rll_green_icon_button', padding=4}, sprite='utility/add'},
            {type='sprite-button', style='red_icon_button', sprite='utility/trash'}
          }},
          {type='scroll-pane', style='rll_subfactory_scroll_pane', children={
            {type='button', style='rll_subfactory_button', caption='[img=item/automation-science-pack]  Roots', mods={enabled=false}},
            {type='button', style='rll_subfactory_button', caption='Yeah Science!'},
            {type='button', style='rll_subfactory_button', caption='[img=item/iron-gear-wheel]  One Ring'},
            {type='button', style='rll_subfactory_button', caption='[img=item/raw-fish]'},
          }}
        }},
        -- info column
        {type='flow', style={vertical_spacing=12}, direction='vertical', children={
          -- info panel
          {type='frame', style={name='window_content_frame', padding=8, horizontally_stretchable=true}, direction='vertical', children={
            {type='label', style='caption_label', caption='Info'},
            -- timescale
            {type='flow', style={vertical_align='center', horizontal_spacing=0}, direction='horizontal', children={
              {type='label', style={right_margin=8}, caption='Timescale [img=info]:'},
              {type='button', style='fp_button_timescale', caption='1s'},
              {type='button', style='fp_button_timescale_selected', mods={enabled=false}, caption='1m'},
              {type='button', style='fp_button_timescale', caption='1h'}
            }},
            -- utilities
            {type='button', style='fp_button_mini', caption='View utilities'},
            -- energy and pollution
            {type='table', column_count=2, draw_vertical_lines=true, children={
              {type='flow', style={right_margin=6}, direction='horizontal', children={
                {type='label', caption='Energy:'},
                {type='label', style='bold_label', caption='118 MW'}
              }},
              {type='flow', style={left_margin=6}, direction='horizontal', children={
                {type='label', caption='Pollution:'},
                {type='label', style='bold_label', caption='1.46 kP/s'}
              }}
            }},
            -- mining productivity
            {type='flow', style={vertical_align='center', horizontal_spacing=6}, direction='horizontal', children={
              {type='label', caption='Mining productivity [img=info]:'},
              {type='label', style='bold_label', caption='25%'},
              {type='button', style='fp_button_mini', caption='Override'}
            }}
          }},
          -- ingredients panel
          {type='frame', style={name='window_content_frame', padding=8}, direction='vertical', children={
            {type='label', style='caption_label', caption='Ingredients'},
            {type='frame', style={name='rll_icon_slot_table_frame'}, children={
              {type='scroll-pane', style={name='rll_icon_slot_table_scrollpane', width=252, height=160}, vertical_scroll_policy='always', children={
                {type='table', style='rll_icon_slot_table', column_count=6, children={
                  {type='sprite-button', style='quick_bar_slot_button', sprite='item/iron-plate', number=5600},
                  {type='sprite-button', style='quick_bar_slot_button', sprite='item/copper-plate', number=1800},
                  {type='sprite-button', style='quick_bar_slot_button', sprite='item/stone', number=1100},
                  {type='sprite-button', style='quick_bar_slot_button', sprite='item/plastic-bar', number=612}
                }}
              }}
            }}
          }},
          -- products panel
          {type='frame', style={name='window_content_frame', padding=8}, direction='vertical', children={
            {type='label', style='caption_label', caption='Products'},
            {type='frame', style={name='rll_icon_slot_table_frame'}, children={
              {type='scroll-pane', style={name='rll_icon_slot_table_scrollpane', width=252, height=160}, vertical_scroll_policy='always', children={
                {type='table', style='rll_icon_slot_table', column_count=6, children={
                  {type='sprite-button', style='rll_slot_button_green', sprite='item/production-science-pack', number=180},
                  {type='sprite-button', style={name='rll_slot_button_light_grey', padding=8}, sprite='utility/add'}
                }}
              }}
            }}
          }},
          -- byproducts panel
          {type='frame', style={name='window_content_frame', padding=8}, direction='vertical', children={
            {type='label', style='caption_label', caption='Byproducts'},
            {type='frame', style={name='rll_icon_slot_table_frame'}, children={
              {type='scroll-pane', style={name='rll_icon_slot_table_scrollpane', width=252, height=160}, vertical_scroll_policy='always', children={
                {type='table', style='rll_icon_slot_table', column_count=6, children={
                  -- empty
                }}
              }}
            }}
          }}
        }},
        -- production pane
        {type='frame', style='inside_deep_frame', direction='vertical', children={
          {type='frame', style='subheader_frame', direction='vertical', children={
            -- toolbar
            {type='flow', style={vertical_align='center'}, children={
              {type='sprite-button', style='tool_button', sprite='utility/refresh'},
              {type='label', style={name='caption_label', left_margin=6, right_margin=4}, caption='Production'},
              {type='label', style='bold_label', caption='Level 1'},
              {type='empty-widget', style={horizontally_stretchable=true}},
              {type='drop-down', items={'items/min', 'belts', 'items/s/[img=item/assembling-machine-3]'}, selected_index=1}
            }},
            {type='flow', style={horizontal_spacing=16}, children={
              {type='label', style={name='bold_label', horizontal_align=column_alignments.recipe, left_margin=4, width=column_widths.recipe}, caption='Recipe'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.percent, width=column_widths.percent}, caption='%'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.machine, width=column_widths.machine}, caption='Machine'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.modules, width=column_widths.modules}, caption='Modules'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.beacons, width=column_widths.beacons}, caption='Beacons'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.energy, width=column_widths.energy}, caption='Energy'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.products, width=column_widths.products}, caption='Products'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.byproducts, width=column_widths.byproducts}, caption='Byproducts'},
              {type='label', style={name='bold_label', horizontal_align=column_alignments.ingredients, width=column_widths.ingredients}, caption='Ingredients'}
            }}
          }},
          -- scroll pane
          {type='scroll-pane', style='rll_rows_scroll_pane', vertical_scroll_policy='auto-and-reserve-space', save_as='production_table_pane'}
        }}
      }}
    }}
  )
  gui_data.drag_handle.drag_target = gui_data.window
  gui_data.window.force_auto_center()

  -- #endregion

  -- populate production table
  local pane = gui_data.production_table_pane
  for i=1,#table_rows do
    local row_data = table_rows[i]
    gui.build_template(pane,
      {type='frame', style='rll_production_table_row_frame', children={
        -- recipe
        {type='flow', style={vertical_align='center', horizontal_align=column_alignments.recipe, width=column_widths.recipe}, direction='horizontal', children={
          {type='sprite-button', style='rll_row_slot_button_'..(row_data.recipe.style or 'dark_grey'), sprite='item/'..row_data.recipe.name}
        }},
        -- percent
        {type='flow', style={vertical_align='center', horizontal_align=column_alignments.percent, width=column_widths.percent}, direction='horizontal',
          children={
          {type='textfield', style={width=55, horizontal_align='center'}, text=row_data.percent}
        }},
        -- machine
        {type='flow', style={vertical_align='center', horizontal_align=column_alignments.machine, width=column_widths.machine}, direction='horizontal',
          children={
          {type='sprite-button', style='rll_row_slot_button_'..(row_data.machine.style or 'dark_grey'), sprite='entity/'..row_data.machine.name,
            number=row_data.machine.number}
        }},
        -- modules
        gui.call_template('items', row_data.modules, 'modules'),
        -- beacons
        gui.call_template('beacons', row_data.beacons),
        -- energy
        {type='flow', style={vertical_align='center', horizontal_align=column_alignments.energy, width=column_widths.energy}, direction='horizontal', children={
          {type='label', caption=row_data.energy}
        }},
        -- products
        gui.call_template('items', row_data.products, 'products'),
        -- byproducts
        gui.call_template('items', row_data.byproducts, 'byproducts'),
        -- ingredients
        gui.call_template('items', row_data.ingredients, 'ingredients')
      }}
    )
  end

end)