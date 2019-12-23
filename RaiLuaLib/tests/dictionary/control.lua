local dictionary = require('lualib/dictionary')
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

local string_lower = string.lower

-- DEBUGGING
event.register('debug-inspect-global', function(e)
  local foo = 'bar'
end)

-- set up dictionary
dictionary.player_setup_function = function(player, build_data)
  dictionary.build(player, 'items_fluids', build_data.items_fluids,
    function(e, prototype)
      return string_lower(e.result), {prototype}
    end,
    function(e, prototype, cur_value)
      table.insert(cur_value, prototype)
      return cur_value, true
    end
  )
end
dictionary.build_setup_function = function(serialise_localised_string)
  local item_fluid_prototypes = {}
  for _,prototype in pairs(game.equipment_prototypes) do
    if not prototype.localised_name == {} then
      item_fluid_prototypes[serialise_localised_string(prototype.localised_name)] = prototype
    end
  end
  for _,prototype in pairs(game.fluid_prototypes) do
    if not prototype.localised_name == {} then
      item_fluid_prototypes[serialise_localised_string(prototype.localised_name)] = prototype
    end
  end
  for _,prototype in pairs(game.item_prototypes) do
    if prototype.name:find('lighted') then
      local foo = 'bar'
    end
    if prototype.localised_name ~= {} then
      item_fluid_prototypes[serialise_localised_string(prototype.localised_name)] = prototype
    end
  end
  return {items_fluids=item_fluid_prototypes}
end

-- test custom events
event.register(dictionary.build_start_event, function(e) util.log('BUILDING DICTIONARY: '..e.dict_name..' for '..game.get_player(e.player_index).name) end)
event.register(dictionary.build_finish_event, function(e) game.get_player(e.player_index).print('Dictionary \''..e.dict_name..'\' built') end)

event.on_init(function()
  for _,p in pairs(game.players) do
    mod_gui.get_button_flow(p).add{type='button', name='rll_dict_button', style=mod_gui.button_style, caption='Search dictionaries'}
  end
end)

event.on_player_created(function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{type='button', name='rll_dict_button', style=mod_gui.button_style, caption='Search dictionaries'}
end)

-- TEST GUI
event.on_gui_click(
  function(e)
    local player = game.get_player(e.player_index)
    local flow = mod_gui.get_frame_flow(player)
    if flow.rll_dict_window then
      flow.rll_dict_window.destroy()
    else
      local window = flow.add{type='frame', name='rll_dict_window', style=mod_gui.frame_style, direction='vertical'}
      window.add{type='textfield', name='rll_dict_textfield'}.focus()
      window.add{type='switch', name='rll_dict_switch', left_label_caption='equipment', right_label_caption='items'}
      window.add{type='flow', name='rll_dict_results_flow', direction='vertical'}
    end
  end,
  {gui_filters='rll_dict_button'}
)

event.on_gui_text_changed(
  function(e)
    local player = game.get_player(e.player_index)
    local search = string_lower(e.element.text)
    local results_flow = mod_gui.get_frame_flow(player).rll_dict_window.rll_dict_results_flow
    results_flow.clear()
    if e.element.text == '' then return end
    local dict_name = e.element.parent.rll_dict_switch.switch_state == 'left' and 'equipment' or 'items'
    -- super simple search function
    local results = {}
    for _,v in pairs(dictionary.get(player, dict_name)) do
      if string.match(string_lower(v), search) then
        table.insert(results, v)
      end
    end
    -- since we only returned a value in the search function, it created an array, so we can use ipairs
    for i,localised in ipairs(results) do
      results_flow.add{type='label', name='rll_dict_result_'..i, caption=localised}
    end
  end,
  {gui_filters='rll_dict_textfield'}
)