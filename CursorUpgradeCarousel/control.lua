-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CURSOR UPGRADE CAROUSEL CONTROL SCRIPTING

-- build upgrade/downgrade registry
local function build_upgrade_registry()
  local prototypes = game.entity_prototypes
  local data = {}
  -- build default registry
  for name,prototype in pairs(prototypes) do
    if prototype.next_upgrade and prototype.items_to_place_this then
      local upgrade = prototype.next_upgrade.name
      for _,item in ipairs(prototype.items_to_place_this) do
        if not data[item.name] then data[item.name] = {} end
        data[item.name].upgrade = upgrade
      end
      for _,item in ipairs(prototypes[upgrade].items_to_place_this) do
        if not data[item.name] then data[item.name] = {} end
        data[item.name].downgrade = name
      end
    end
  end
  -- build custom registry
  for name,upgrade in pairs(load('return '..settings.global['cuc-custom-upgrade-registry'].value)()) do
    -- get objects and validate them, or error if not
    local prototype = prototypes[name]
    if not prototype then
      game.print{'chat-message.invalid-name', name}
      goto continue
    end
    local upgrade_prototype = prototypes[upgrade]
    if not upgrade_prototype then
      game.print{'chat-message.invalid-upgrade-name', upgrade}
      goto continue
    end
    for _,item in ipairs(prototype.items_to_place_this or {}) do
      if not data[item.name] then data[item.name] = {} end
      data[item.name].upgrade = upgrade
    end
    for _,item in ipairs(upgrade_prototype.items_to_place_this or {}) do
      if not data[item.name] then data[item.name] = {} end
      data[item.name].downgrade = name
    end
    ::continue::
  end
  global.registry = data
end

script.on_init(function()
  build_upgrade_registry()
end)

script.on_configuration_changed(function(e)
  build_upgrade_registry()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == 'cuc-custom-upgrade-registry' then
    build_upgrade_registry()
  end
end)

script.on_event({'cuc-cycle-forwards', 'cuc-cycle-backwards'}, function(e)
  local player = game.players[e.player_index]
  local stack = player.cursor_stack
  local name
  -- check cursor stack and cursor ghost and set the name accordingly
  if stack and stack.valid_for_read then
    name = stack.name
  elseif player.cursor_ghost then
    name = player.cursor_ghost.name
  else
    return
  end
  local registry = global.registry
  -- get upgrade or downgrade depending on event
  local grade = e.input_name:find('forwards') and 'upgrade' or 'downgrade'
  -- if we're in the map editor and the setting is enabled, always give the actual item
  local always_give = player.mod_settings['cuc-always-give-in-map-editor'].value
  -- if the thing we're holding has an upgrade/downgrade
  if registry[name] and registry[name][grade] then
    player.clean_cursor()
    local grade_name = registry[name][grade]
    local inventory = player.get_main_inventory()
    local contents = inventory.get_contents()
    local grade_items = game.entity_prototypes[grade_name].items_to_place_this
    for _,item in ipairs(grade_items) do
      if contents[item.name] then
        -- we actually have this item, so replace the cursor stack from the inventory
        stack.set_stack{name=item.name, count=inventory.remove{name=item.name, count=game.item_prototypes[item.name].stack_size}}
        return
      elseif always_give and player.controller_type == defines.controllers.editor then
        -- replace the cursor stack without taking from the inventory
        stack.set_stack{name=item.name, count=game.item_prototypes[item.name].stack_size}
        return
      end
    end
    -- if we're here, then they don't have any of the items, so put the first one in the ghost cursor
    player.cursor_ghost = grade_items[1].name
  end
end)