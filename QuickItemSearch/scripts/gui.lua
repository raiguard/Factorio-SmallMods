-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI

local event = require("__RaiLuaLib__.lualib.event")
local gui = require("__RaiLuaLib__.lualib.gui")

local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower

local qis_gui = {}

-- -----------------------------------------------------------------------------
-- SEARCH AND ACTIONS

local function search(player, player_table, query)
  local player_settings = player_table.settings
  local results_table = player_table.gui.results_table
  local children = results_table.children
  local translations = player_table.translations
  local item_data = global.item_data
  local add = results_table.add
  local index = 0
  local results = {}
  local button_indexes = {}

  local show_hidden = player_settings.search_hidden

  -- add or update the next result button
  local function set_result(type, name, number)
    index = index + 1
    results[name] = number
    local button = children[index]
    if button then
      button.style = "qis_slot_button_"..type
      button.sprite = "item/"..name
      button.tooltip = translations[name]
      button.number = number
    else
      button = add{type="sprite-button", name="qis_result_button_"..index, style="qis_slot_button_"..type, sprite="item/"..name, number=number,
        tooltip=translations[name], mouse_button_filter={"left"}}
    end
    button_indexes[index] = button.index
  end

  -- match the query to the given name
  local function match_query(name, translation, ignore_unique)
    return (ignore_unique or not results[name]) and (show_hidden or not item_data[name].hidden)
      and string_find(string_lower(translation or translations[name]), query)
  end

  -- map editor
  if player.controller_type == defines.controllers.editor then
    local contents = player.get_main_inventory().get_contents()
    for internal,translated in pairs(translations) do
      -- we don't care about hidden or other results, so use an optimised condition
      if string_find(string_lower(translated), query) then
        set_result("inventory", internal, contents[internal])
      end
    end
  else
    -- player inventory
    if player_settings.search_inventory then
      local contents = player.get_main_inventory().get_contents()
      for name,count in pairs(contents) do
        if match_query(name) then
          set_result("inventory", name, count)
        end
      end
    end
    -- logistic network(s)
    if player.character and player_settings.search_logistics then
      local ignore_unique = not player_settings.logistics_unique_only
      local character = player.character
      local network_contents = {}
      for _,point in ipairs(character.get_logistic_point()) do
        local network = point.logistic_network
        if network.valid and network.all_logistic_robots > 0 then
          local contents = point.logistic_network.get_contents()
          for name,count in pairs(contents) do
            if match_query(name, nil, not network_contents[name] and ignore_unique) then
              network_contents[name] = count
              set_result("logistics", name, count)
            end
          end
        end
      end
    end
    -- unavailable
    if player_settings.search_unavailable then
      for internal,translated in pairs(translations) do
        if match_query(internal, translated) then
          set_result("unavailable", internal)
        end
      end
    end
  end

  -- remove extra buttons, if any
  for i=index+1, #children do
    children[i].destroy()
  end
end

-- -----------------------------------------------------------------------------
-- GUI DATA

local sanitizers = {
  ["%("] = "%%(",
  ["%)"] = "%%)",
  ["%.^[%*]"] = "%%.",
  ["%+"] = "%%+",
  ["%-"] = "%%-",
  ["^[%.]%*"] = "%%*",
  ["%?"] = "%%?",
  ["%["] = "%%[",
  ["%]"] = "%%]",
  ["%^"] = "%%^",
  ["%$"] = "%%$"
}

gui.templates:extend{
  logistic_request_setter = {type="flow", style_mods={vertical_align="center", horizontal_spacing=10}, children={
    {type="slider", style_mods={minimal_width=130, horizontally_stretchable=true}},
    {type="textfield", style_mods={width=60, horizontal_align="center"}, numerical=true, lose_focus_on_confirm=true}
  }}
}

gui.handlers:extend{
  search_textfield = {
    on_gui_click = function(e)
      local player = game.get_player(e.player_index)
      local player_table = global.players[e.player_index]
      game.print(serpent.block(e))
    end,
    on_gui_closed = function(e)
      local player = game.get_player(e.player_index)
      local player_table = global.players[e.player_index]
      game.print(serpent.block(e))
    end,
    on_gui_text_changed = function(e)
      local player = game.get_player(e.player_index)
      local player_table = global.players[e.player_index]
      local query = e.element.text
      
      -- fuzzy search
      if player_table.settings.fuzzy_search then
        query = string_gsub(query, ".", "%1.*")
      end
      -- input sanitization
      for pattern, replacement in pairs(sanitizers) do
        query = string_gsub(query, pattern, replacement)
      end

      -- TODO: non-essential search smarts

      search(player, player_table, query)
    end,
    on_gui_confirmed = function(e)
      local player = game.get_player(e.player_index)
      local player_table = global.players[e.player_index]
      game.print(serpent.block(e))
    end
  },
  result_button_click = {id=defines.events.on_gui_click, handler=function(e)
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    game.print(serpent.block(e))
  end, gui_filters="qis_result_button_", options={match_filter_strings=true}},
  keys_nav = {id={"qis-nav-left", "qis-nav-up", "qis-nav-right", "qis-nav-down"}, handler=function(e)
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    game.print(serpent.block(e))
  end},
  keys_confirm = {id={"qis-nav-confirm", "qis-nav-shift-confirm", "qis-nav-control-confirm"}, handler=function(e)
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    game.print(serpent.block(e))
  end}
}

function qis_gui.create(player, player_table)
  -- GUI prototyping
  local gui_data = gui.build(player.gui.screen, {
    {type="frame", style="dialog_frame", direction="vertical", save_as="window", children={
      {type="textfield", style="qis_main_textfield", clear_and_focus_on_right_click=true, handlers="search_textfield", save_as="search_textfield"},
      {type="flow", children={
        {type="frame", style="qis_content_frame", style_mods={padding=12}, mods={visible=true}, children={
          {type="frame", style="qis_results_frame", children={
            {type="scroll-pane", style="qis_results_scroll_pane", children={
              {type="table", style="qis_results_table", column_count=5, save_as="results_table"}
            }}
          }}
        }},
        -- {type="frame", style="qis_content_frame", style_mods={padding=0}, direction="vertical", mods={visible=false}, children={
        --   {type="frame", style="subheader_frame", style_mods={height=30}, children={
        --     {type="label", style="caption_label", style_mods={left_margin=4}, caption="Logistics request"},
        --     {type="empty-widget", style_mods={horizontally_stretchable=true}},
        --     {type="sprite-button", style="green_button", style_mods={width=24, height=24, padding=0, top_margin=1}, sprite="utility/confirm_slot"}
        --   }},
        --   {type="flow", style_mods={top_padding=2, left_padding=10, right_padding=8}, direction="vertical", children={
        --     {template="logistic_request_setter"},
        --     {template="logistic_request_setter"}
        --   }}
        -- }}
      }}
    }}
  })

  event.enable("gui.result_button_click", player.index)

  gui_data.window.force_auto_center()
  gui_data.search_textfield.focus()

  player.opened = gui_data.search_textfield
  gui_data.state = "search"

  player_table.gui = gui_data
end

return qis_gui