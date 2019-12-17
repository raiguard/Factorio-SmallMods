-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAI'S EVENT LIBRARY

-- DOCUMENTATION: https://github.com/raiguard/SmallFactorioMods/wiki/Event-Library-Documentation

-- library
local event = {}
-- holds registered events
local event_registry = {}
-- pass-through handlers for special events
local bootstrap_handlers = {
  on_init = function()
    event.dispatch{name='on_init'}
  end,
  on_load = function()
    event.dispatch{name='on_load'}
  end,
  on_configuration_changed = function(e)
    e.name = 'on_configuration_changed'
    event.dispatch(e)
  end
}

function event.register(id, handler, options)
  options = options or {}
  -- add to conditional event registry if needed
  local name = options.name
  if name then
    local player_index = options.player_index
    local con_registry = global.conditional_event_registry[name]
    if not con_registry then
      global.conditional_event_registry[name] = {id=id, players={player_index}, gui_filters=options.gui_filters}
    elseif player_index then
      table.insert(con_registry.players, player_index)
      return event -- don't do anything else
    end
  end
  -- register handler
  if type(id) ~= 'table' then id = {id} end
  for _,n in pairs(id) do
    -- create event registry if it doesn't exist
    if not event_registry[n] then
      event_registry[n] = {}
    end
    local registry = event_registry[n]
    -- create master handler if not already created
    if #registry == 0 then
      if type(n) == 'number' and n < 0 then
        script.on_nth_tick(-n, event.dispatch)
      elseif type(n) == 'string' and bootstrap_handlers[n] then
        script[n](bootstrap_handlers[n])
      else
        script.on_event(n, event.dispatch)
      end
    end
    -- make sure the handler has not already been registered
    for i,t in ipairs(registry) do
      -- if it is a conditional event,
      if t.handler == handler and not name then
        -- remove handler for re-insertion at the bottom
        log('Re-registering existing event ID, moving to bottom')
        table.remove(registry, i)
      end
    end
    -- add the handler to the events table
    table.insert(registry, {handler=handler, name=name, gui_filters=options.gui_filters})
  end
  return event -- function call chaining
end

function event.deregister(id, handler, options)
  options = options or {}
  local name = options.name
  local player_index = options.player_index
  -- remove from conditional event registry if needed
  if name then
    local con_registry = global.conditional_event_registry[name]
    if con_registry then
      if player_index then
        for i,pi in ipairs(con_registry.players) do
          if pi == player_index then
            table.remove(con_registry.players, i)
          end
        end
      end
      if #con_registry.players == 0 then
        global.conditional_event_registry[name] = nil
      end
    else
      error('Tried to deregister a conditional event whose data does not exist')
    end
  end
  -- deregister handler
  if type(id) ~= 'table' then id = {id} end
  for _,n in pairs(id) do
    local registry = event_registry[n]
    -- error checking
    if not registry or #registry == 0 then
      log('Tried to deregister an unregistered event of id: '..n)
      return event
    end
    -- remove the handler from the events tables
    for i,t in ipairs(registry) do
      if t.handler == handler then
        table.remove(registry, i)
      end
    end
    -- de-register the master handler if it's no longer needed
    if table_size(registry) == 0 then
      if type(n) == 'number' and n < 0 then
        script.on_nth_tick(math.abs(n), nil)
      elseif type(n) == 'string' and bootstrap_handlers[n] then
        script[n](nil)
      else
        script.on_event(n, nil)
      end
    end
  end
  return event
end

local gui_filter_handlers = {
  string = function(element, filter) return element.name:match(filter) end,
  number = function(element, filter) return element.id == filter end,
  table = function(element, filter) return element == filter end
}

-- DO NOT CALL THIS FUNCTION - USE EVENT.RAISE INSTEAD
function event.dispatch(e)
  local id = e.name
  if e.nth_tick then
    id = -e.nth_tick
  end
  if not event_registry[id] then
    if e.input_name and event_registry[e.input_name] then
      id = e.input_name
    else
      error('Event is registered but has no handlers!')
    end
  end
  local con_registry = global.conditional_event_registry
  for _,t in ipairs(event_registry[id]) do
    -- check if any userdata has gone invalid since last iteration
    for _,v in pairs(e) do
      if type(v) == 'table' and v.__self and not v.valid then
        return event
      end
    end
    -- insert registered players if necessary
    if t.name then
      e.registered_players = con_registry[t.name] and con_registry[t.name].players
    end
    -- check GUI filters if they exist
    local filters = t.gui_filters
    if filters then
      -- error checking
      if not e.element then
        error('Event \''..e.name..'\' does not support GUI filters.')
      end
      -- nest into an array if it's not in one
      if type(filters) ~= 'table' or filters.gui then
        filters = {filters}
      end
      for _,filter in pairs(filters) do
        if gui_filter_handlers[type(filter)](e.element, filter) then
          goto call_handler
        end
      end
      -- if we're here, none of the filters matched, so don't call the handler
      goto continue
    end
    ::call_handler::
    -- call the handler
    t.handler(e)
    ::continue::
  end
  return event
end

function event.raise(id, table)
  script.raise_event(id, table)
  return event
end

function event.set_filters(id, filters)
  if type(id) ~= 'table' then id = {id} end
  for _,n in pairs(id) do
    script.set_event_filter(n, filters)
  end
  return event
end

-- holds custom event IDs
local custom_id_registry = {}
function event.generate_id(name)
  if not custom_id_registry[name] then
    custom_id_registry[name] = script.generate_event_name()
  end
  return custom_id_registry[name], event
end

-- -------------------------------------
-- SHORTCUT FUNCTIONS

-- bootstrap events
function event.on_init(handler)
  return event.register('on_init', handler)
end

function event.on_load(handler)
  return event.register('on_load', handler)
end

function event.on_configuration_changed(handler)
  return event.register('on_configuration_changed', handler)
end

function event.on_nth_tick(nthTick, handler, conditional_name, player_index)
  return event.register(-nthTick, handler, conditional_name, player_index)
end

-- defines.events
for n,id in pairs(defines.events) do
  event[n] = function(handler, conditional_name, player_index)
    event.register(id, handler, conditional_name, player_index)
  end
end

-- -----------------------------------------------------------------------------
-- CONDITIONAL EVENTS

-- create global table for conditional events on init
event.on_init(function()
  global.conditional_event_registry = {}
end)

function event.load_conditional_handlers(data)
  for name, handler in pairs(data) do
    local registry = global.conditional_event_registry[name]
    if registry then
        event.register(registry.id, handler, {name=name, gui_filters=registry.gui_filters, skip_error=true})
    end
  end
  return event
end

function event.is_registered(name)
  return global.conditional_event_registry[name] and true or false
end

return event