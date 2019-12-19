local dictionary = require('lualib/dictionary')
local event = require('lualib/event')
local util = require('lualib/util')

local mod_gui = require('mod-gui')

-- setup localised dictionary
dictionary.setup_function = function(player)
  local prototype_dictionary = {}
  for _,prototype in pairs(game.item_prototypes) do
    prototype_dictionary[prototype.localised_name[1]] = {type='item', prototype=prototype}
  end
  for _,prototype in pairs(game.equipment_prototypes) do
    prototype_dictionary[prototype.localised_name[1]] = {type='equipment', prototype=prototype}
  end
  return prototype_dictionary
end
dictionary.get_data_function = function(e, data)
  return data.prototype.name, {
    type = data.type,
    name = string.lower(e.result)
  }
end

-- test events
event.register(dictionary.build_start_event, function(e) util.log('dictionary build started for '..game.players[e.player_index].name) end)
event.register(dictionary.build_finish_event, function(e) util.get_player(e).print('Localised dictionary built') end)

-- test GUI
local function setup_player(player)
  mod_gui.get_button_flow(player).add{type='button', name='rll_dict_button', style=mod_gui.button_style, caption='Search'}
end

event.on_init(function()
  for i,p in pairs(game.players) do
    setup_player(p)
  end
end)

-- test GUI
event.on_player_created(function(e)
  setup_player(util.get_player(e))
end)

event.on_gui_click(
  function(e)
    local player = util.get_player(e)
    local flow = mod_gui.get_frame_flow(player)
    if flow.rll_dict_window then
      flow.rll_dict_window.destroy()
    else
      local window = flow.add{type='frame', name='rll_dict_window', style=mod_gui.frame_style, direction='vertical'}
      window.add{type='textfield', name='rll_dict_textfield'}.focus()
      window.add{type='flow', name='rll_dict_results_flow', direction='vertical'}
    end
  end,
  {gui_filters='rll_dict_button'}
)

event.on_gui_text_changed(
  function(e)
    local player = util.get_player(e)
    local search = string.lower(e.element.text)
    local results_flow = mod_gui.get_frame_flow(player).rll_dict_window.rll_dict_results_flow
    results_flow.clear()
    if e.element.text == '' then return end
    -- super simple search function
    local results = dictionary.search(player, function(k,v)
      if v.name:match(search) then
        return v.name,k
      end
    end)
    local i = 0
    for internal,localised in pairs(results) do
      i = i + 1
      results_flow.add{type='label', name='rll_dict_result_'..i, caption=localised}
    end
  end,
  {gui_filters='rll_dict_textfield'}
)