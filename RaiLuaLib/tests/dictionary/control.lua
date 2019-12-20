local dictionary = require('lualib/dictionary')
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

local string_lower = string.lower

-- set up dictionary
dictionary.player_setup_function = function(player)
  local item_prototypes = {}
  for _,prototype in pairs(game.item_prototypes) do
    item_prototypes[prototype.localised_name[1]] = prototype
  end
  local equipment_prototypes = {}
  for _,prototype in pairs(game.equipment_prototypes) do
    equipment_prototypes[prototype.localised_name[1]] = prototype
  end
  local function dictionary_translation_function(e, data)
    return data.name, e.result
  end
  dictionary.build(player, 'equipment', equipment_prototypes, dictionary_translation_function)
  dictionary.build(player, 'items', item_prototypes, dictionary_translation_function)
end
dictionary.use_builtin_event_handlers()

-- test custom events
event.register(dictionary.build_start_event, function(e) util.log('BUILDING DICTIONARY: '..e.dict_name..' for '..game.get_player(e.player_index).name) end)
event.register(dictionary.build_finish_event, function(e) game.get_player(e.player_index).print('Dictionary \''..e.dict_name..'\' built') end)

event.on_init(function()
  for i,p in pairs(game.players) do
    mod_gui.get_button_flow(p).add{type='button', name='rll_dict_button', style=mod_gui.button_style, caption='Search dictionaries'}
  end
end)

event.on_player_created(function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{type='button', name='rll_dict_button', style=mod_gui.button_style, caption='Search dictionaries'}
end)

-- TEST GUI
event.on_gui_click(
  function(e)
    local player = util.get_player(e)
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
    local player = util.get_player(e)
    local search = string_lower(e.element.text)
    local results_flow = mod_gui.get_frame_flow(player).rll_dict_window.rll_dict_results_flow
    results_flow.clear()
    if e.element.text == '' then return end
    local dict_name = e.element.parent.rll_dict_switch.switch_state == 'left' and 'equipment' or 'items'
    -- super simple search function
    local results = dictionary.search(dictionary.get(player, dict_name), function(k,v)
      if string.match(string_lower(v), search) then
        return v
      end
    end)
    -- since we only returned a value in the search function, it created an array, so we can use ipairs
    for i,localised in ipairs(results) do
      results_flow.add{type='label', name='rll_dict_result_'..i, caption=localised}
    end
  end,
  {gui_filters='rll_dict_textfield'}
)