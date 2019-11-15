-- ----------------------------------------------------------------------------------------------------
-- RAI'S EVENT HANDLER
-- Allows one to easily register multiple handlers for an event
-- Makes handling of conditional events far easier
-- Does not support event filters

-- library
local event = {}
-- holds registered events
local event_registry = {}
-- pass-through handlers for bootstrap events
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

-- register a handler for an event
-- when registering a conditional event, pass a unique conditional name as the third argument
function event.register(id, handler, conditional_name)
    -- recursive handling of ids
    if type(id) == 'table' then
        for _,n in pairs(id) do
            event.register(n, handler, conditional_name)
        end
        return
    end
    -- create event registry if it doesn't exist
    if not event_registry[id] then
        event_registry[id] = {}
    end
    local registry = event_registry[id]
    -- make sure the handler has not already been registered
    for _,t in ipairs(registry) do
        if t.handler == handler then
            -- don't register or insert handler
            log('Tried to register event handler that already exists of id: '..id)
            return
        end
    end
    -- create master handler if not already created
    if #registry == 0 then
        if type(id) == 'number' and id < 0 then
            script.on_nth_tick(math.abs(id), event.dispatch)
        elseif type(id) == 'string' and bootstrap_handlers[id] then
            script[id](bootstrap_handlers[id])
        else
            script.on_event(id, event.dispatch)
        end
    end
    -- add the handler to the events tables
    table.insert(registry, {handler=handler})
    if conditional_name then
        local con_registry = global.conditional_event_registry
        if not con_registry[conditional_name] then
            con_registry[conditional_name] = {id}
        else
            table.insert(con_registry[conditional_name], id)
        end
    end
end

-- deregisters a handler for an event
-- when deregistering a conditional event, pass its unique conditional name as the third argument
function event.deregister(id, handler, conditional_name)
    -- recursive handling of ids
    if type(id) == 'table' then
        for _,n in pairs(id) do
            event.deregister(n, handler, conditional_name)
        end
        return
    end
    local registry = event_registry[id]
    -- error checking
    if not registry or #registry == 0 then
        log('Tried to deregister an unregistered event of id: '..id)
        return
    end
    -- remove the handler from the events tables
    for i,t in ipairs(registry) do
        if t.handler == handler then
            table.remove(registry, i)
        end
    end
    if conditional_name then
        local con_registry = global.conditional_event_registry[conditional_name]
        for i,n in pairs(con_registry) do
            if n == id then table.remove(con_registry, i) end
        end
        if #con_registry == 0 then
            global.conditional_event_registry[conditional_name] = nil
        end
    end
    -- de-register the master handler if it's no longer needed
    if #registry == 0 then
        if type(id) == 'number' and id < 0 then
            script.on_nth_tick(math.abs(id), nil)
        elseif type(id) == 'string' and bootstrap_handlers[id] then
            script[id](nil)
        else
            script.on_event(id, nil)
        end
    end
end

-- invokes all handlers for an event
-- used both by actual event handlers, and can be called manually
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
            return
        end
    end
    for _,t in ipairs(event_registry[id]) do
        t.handler(e)
    end
end

-- shortcut for event.register('on_init', function)
function event.on_init(handler)
    event.register('on_init', handler)
end

-- shortcut for event.register('on_load', function)
function event.on_load(handler)
    event.register('on_load', handler)
end

-- shortcut for event.register('on_configuration_changed', function)
function event.on_configuration_changed(handler)
    event.register('on_configuration_changed', handler)
end

-- shortcut for event.register(-nthTick, function)
function event.on_nth_tick(nthTick, handler, conditional_name)
    event.register(-nthTick, handler, conditional_name)
end

--
-- CONDITIONAL EVENTS
--

-- create global table for conditional events
event.on_init(function()
    global.conditional_event_registry = {}
end)

-- for use in on_load: registers a conditional event handler if it is included in the conditional events registry
function event.load_conditional_events(data)
    for name, handler in pairs(data) do
        if global.conditional_event_registry[name] then
            event.register(global.conditional_event_registry[name], handler)
        end
    end
end

return event