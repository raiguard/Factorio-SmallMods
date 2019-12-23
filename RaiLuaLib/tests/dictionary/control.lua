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
  -- STRESS TESTING
  dictionary.build(player, 'items_fluids', build_data.items_fluids.prototypes, build_data.items_fluids.iteration,
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
  local item_fluid_iteration = {}
  for _,prototype in pairs(game.equipment_prototypes) do
    if not prototype.localised_name == {} then
      item_fluid_prototypes[serialise_localised_string(prototype.localised_name)] = prototype
      table.insert(item_fluid_iteration, prototype.localised_name)
    end
  end
  for _,prototype in pairs(game.fluid_prototypes) do
    if not prototype.localised_name == {} then
      item_fluid_prototypes[serialise_localised_string(prototype.localised_name)] = prototype
      table.insert(item_fluid_iteration, prototype.localised_name)
    end
  end
  for _,prototype in pairs(game.item_prototypes) do
    if prototype.localised_name ~= {} then
      item_fluid_prototypes[serialise_localised_string(prototype.localised_name)] = prototype
      table.insert(item_fluid_iteration, prototype.localised_name)
    end
  end
  return {items_fluids={prototypes=item_fluid_prototypes, iteration=item_fluid_iteration}}
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
      if dictionary.get(player, 'items_fluids') then
        local window = flow.add{type='frame', name='rll_dict_window', style=mod_gui.frame_style, direction='vertical'}
        window.add{type='textfield', name='rll_dict_textfield'}.focus()
        window.add{type='flow', name='rll_dict_results_flow', direction='vertical'}
      end
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
    -- super simple search function
    local i = 0
    for name,t in pairs(dictionary.get(player, 'items_fluids')) do
      if string.find(name, search) then
        for _,prototype in ipairs(t) do
          i = i + 1
          results_flow.add{type='label', name='rll_dict_result_'..i, caption=prototype.localised_name}
        end
      end
    end
  end,
  {gui_filters='rll_dict_textfield'}
)