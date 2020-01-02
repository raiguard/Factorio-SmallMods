-- TAB EVENT TEST

local function setup_player(player)
  global.players[player.index] = {}
  local tabbed_pane = player.gui.screen.add{type='tabbed-pane', name='sandbox_test_pane'}
  tabbed_pane.style.width = 500
  -- add tabs
  for i=1,20 do
    local tab = tabbed_pane.add{type='tab', name='tab_'..i, caption='Tab '..i}
    local content = tabbed_pane.add{type='empty-widget', name='content_'..i}
    content.style.width = 490
    content.style.height = 300
    tabbed_pane.add_tab(tab, content)
  end
end

script.on_init(function()
  global.players = {}
  for i,p in pairs(game.players) do
    setup_player(p)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  setup_player(game.get_player(e.player_index))
end)

script.on_event(defines.events.on_gui_click, function(e)
  if e.element.type == 'tab' then
    game.print(serpent.block(e))
  end
end)