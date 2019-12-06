-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICKBAR TEMPLATES CONTROL SCRIPTING

-- -----------------------------------------------------------------------------
-- UTILITIES

-- create the GUI
local function create_gui(player)
    local player_index = player.index
    local window = player.gui.screen.add{type='frame', name='qt_window', style='shortcut_bar_window_frame'}
    window.style.right_padding = 4
    local inner_panel = window.add{type='frame', name='qt_inner_panel', style='shortcut_bar_inner_panel'}
    local export_button = inner_panel.add{type='sprite-button', name='qt_export_button', style='shortcut_bar_button_blue', sprite='qt-export-blueprint-white',
                                          tooltip={'gui-quickbar-templates.export-button-tooltip'}}
    local import_button = inner_panel.add{type='sprite-button', name='qt_import_button', style='shortcut_bar_button_blue', sprite='qt-import-blueprint-white',
                                          tooltip={'gui-quickbar-templates.import-button-tooltip'}}
    window.visible = false
    return {window=window, export_button=export_button, import_button=import_button}
end

-- setup player global table and GUI
local function setup_player(player)
    local data = create_gui(player)
    global.players[player.index] = data
    return data.window
end

-- set window location relative to the player's quickbar
local function set_gui_location(player, window)
    local resolution = player.display_resolution
    local scale = player.display_scale
    window.location = {
        x = (resolution.width / 2) - ((56 + 258) * scale),
        y = (resolution.height - (56 * scale))
    }
end

-- -----------------------------------------------------------------------------
-- QUICKBAR

-- export the current quickbar filters to a blueprint
local function export_quickbar(player)
    -- get quickbar filters
    local get_slot = player.get_quick_bar_slot
    local filters = {}
    for i=1,100 do
        local item = get_slot(i)
        if item then
            filters[i] = item.name
        end
    end
    -- assemble blueprint entities
    local entities = {}
    local pos = {x=-4,y=4}
    for i=1,100 do
        -- add blank combinator
        entities[i] = {
            entity_number = i,
            name = 'constant-combinator',
            position = {x=pos.x, y=pos.y},
        }
        -- set combinator signal if there's a filter
        if filters[i] ~= nil then
            entities[i].control_behavior = {
                filters = {
                    {
                        count = 1,
                        index = 1,
                        signal = {
                            name = filters[i],
                            type = 'item'
                        }
                    }
                }
            }
        end
        -- adjust position for next entity
        pos.x = pos.x + 1
        if pos.x == 6 then
            pos.x = -4
            pos.y = pos.y - 1
        end
    end
    return entities
end

-- apply the filters from the given blueprint to our quickbar
local function import_quickbar(player, entities)
    -- get filters, while at the same time checking for the blueprint's validity
    if #entities ~= 100 then
        player.print{'chat-message.invalid-blueprint'}
        return
    end
    for i=1,100 do
        local entity = entities[i]
        -- check if this is a constant combinator
        if entity == nil or entity.name ~= 'constant-combinator' then
            player.print{'chat-message.invalid-blueprint'}
            return
        end
        if entity.control_behavior then
            -- if the combinator behavior has more than one filter, it's invalid
            if #entity.control_behavior.filters > 1 then
                player.print{'chat-message.invalid-blueprint'}
                return
            end
            -- get_blueprint_entities() does not return them in any particular order for some reason, so calculate the index by position
            local pos = entity.position
            player.set_quick_bar_slot(46 + (pos.x) + (-pos.y*10), entities[i].control_behavior.filters[1].signal.name)
        end
    end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- on init
script.on_init(function()
    global.players = {}
    for _,player in pairs(game.players) do
        local window = setup_player(player)
        set_gui_location(player, window)
    end
end)

-- when a player is created
script.on_event(defines.events.on_player_created, function(e)
    local player = game.players[e.player_index]
    setup_player(player)
    -- apply default template if one is set up
    local template = player.mod_settings['qt-default-template'].value
    if template ~= '' then
        local inventory = player.get_main_inventory()
        inventory.insert{name='blueprint'}
        -- get the blueprint back
        local blueprint
        for i=1,#inventory do
            if inventory[i].name == 'blueprint' and not inventory[i].is_blueprint_setup() then
                blueprint = inventory[i]
                break
            end
        end
        if not blueprint then error('No blueprint found, is inventory full?') end
        -- import the default template
        if blueprint.import_stack(template) == 0 then
            -- apply to quickbar
            import_quickbar(player, blueprint.get_blueprint_entities())
        else
            -- error
            game.print{'chat-message.invalid-blueprint'}
        end
        -- remove blueprint
        blueprint.clear()
    end
end)

-- when a player's cursor stack changes
script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
    local player = game.players[e.player_index]
    local gui = global.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'blueprint' then
        -- show GUI
        if stack.is_blueprint_setup() then
            gui.export_button.visible = false
            gui.import_button.visible = true
        else
            gui.export_button.visible = true
            gui.import_button.visible = false
        end
        gui.window.visible = true
    elseif gui.window.visible then
        -- hide GUI
        gui.window.visible = false
    end
end)

-- when a player's display resolution or scale changes
script.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(e)
    set_gui_location(game.players[e.player_index], global.players[e.player_index].window)
end)

-- when a player clicks a GUI button
script.on_event(defines.events.on_gui_click, function(e)
    if e.element.name == 'qt_export_button' then
        local player = game.players[e.player_index]
        local stack = player.cursor_stack
        if stack and stack.valid_for_read and stack.name == 'blueprint' then
            -- export to held blueprint
            stack.set_blueprint_entities(export_quickbar(player))
        end
    elseif e.element.name == 'qt_import_button' then
        local player = game.players[e.player_index]
        local stack = player.cursor_stack
        if stack and stack.valid_for_read and stack.name == 'blueprint' then
            -- import from held blueprint
            import_quickbar(player, stack.get_blueprint_entities())
        end
    end
end)