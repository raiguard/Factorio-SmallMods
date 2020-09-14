-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROL SCRIPTING

local util = require('__core__/lualib/util')

-- -----------------------------------------------------------------------------
-- UPGRADE REGISTRY ASSEMBLY

-- build the default upgrade/downgrade registry
local function build_default_registry()
  local prototypes = game.entity_prototypes
  local data = {}
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
  global.default_registry = data
end

-- apply a player's overrides to create their custom registry
local function apply_registry_overrides(player)
  local prototypes = game.entity_prototypes
  local data = table.deepcopy(global.default_registry)
  local registry = game.json_to_table(player.mod_settings['cuc-custom-upgrade-registry'].value)
  if not registry or type(registry) == "string" then
    player.print{'cuc-message.invalid-string'}
    return data
  end
  for name,upgrade in pairs(registry) do
    -- get objects and validate them, or error if not
    local prototype = prototypes[name]
    if not prototype then
      player.print{'cuc-message.invalid-name', name}
      goto continue
    end
    local upgrade_prototype = prototypes[upgrade]
    if not upgrade_prototype then
      player.print{'cuc-message.invalid-upgrade-name', upgrade}
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
  return data
end

-- refresh all registries
local function refresh_registries()
  build_default_registry()
  for i,p in pairs(game.players) do
    global.players[i].registry = apply_registry_overrides(p)
  end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

script.on_init(function()
  global.players = {}
  -- create player tables
  global.players = {}
  for i,_ in pairs(game.players) do
    global.players[i] = {}
  end
  -- create registries
  refresh_registries()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == 'cuc-custom-upgrade-registry' then
    global.players[e.player_index].registry = apply_registry_overrides(game.get_player(e.player_index))
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  local data = {}
  data.registry = apply_registry_overrides(game.get_player(e.player_index))
  global.players[e.player_index] = data
end)

script.on_event(defines.events.on_player_removed, function(e)
  global.players[e.player_index] = nil
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
  local registry = global.players[e.player_index].registry
  -- get upgrade or downgrade depending on event
  local grade = e.input_name:find('forwards') and 'upgrade' or 'downgrade'
  -- if we're in the map editor or cheat mode, and the setting is enabled, always give the actual item
  local spawn_item = player.mod_settings['cuc-spawn-items-when-cheating'].value
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
      elseif spawn_item and (player.cheat_mode or (player.controller_type == defines.controllers.editor)) then
        -- replace the cursor stack without taking from the inventory
        stack.set_stack{name=item.name, count=game.item_prototypes[item.name].stack_size}
        return
      end
    end
    -- if we're here, then they don't have any of the items, so put the first one in the ghost cursor
    player.cursor_ghost = grade_items[1].name
  end
end)

-- -----------------------------------------------------------------------------
-- MIGRATIONS

-- table of migration functions
local migrations = {
  ['1.1.0'] = function()
    -- remove old registry location
    global.registry = nil
    -- create player tables
    global.players = {}
    for i,_ in pairs(game.players) do
      global.players[i] = {}
    end
  end
}

-- returns true if v2 is newer than v1, false if otherwise
local function compare_versions(v1, v2)
  local v1_split = util.split(v1, '.')
  local v2_split = util.split(v2, '.')
  for i=1,#v1_split do
    if v1_split[i] < v2_split[i] then
      return true
    elseif v1_split[i] > v2_split[i] then
      return false
    end
  end
  return false
end

script.on_configuration_changed(function(e)
  -- version migrations
  local changes = e.mod_changes[script.mod_name]
  if changes then
    local old = changes.old_version
    if old then
      local migrate = false
      for v,f in pairs(migrations) do
        if migrate or compare_versions(old, v) then
          migrate = true
          f(e)
        end
      end
    else
      return -- don't do generic migrations because we just initialized
    end
  end
  -- global migrations
  refresh_registries()
end)