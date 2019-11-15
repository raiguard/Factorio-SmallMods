-- ----------------------------------------------------------------------------------------------------
-- EVENT HANDLER
-- Allows one to easily register multiple handlers for an event

-- library
local this = {}
-- holds registered events
local event_registry = {}
-- pass-through handlers for bootstrap events
local bootstrap_handlers = {
    on_init = function()
        this.dispatch{name='on_init'}
    end,
    on_load = function()
        this.dispatch{name='on_load'}
    end,
    on_configuration_changed = function(e)
        e.name = 'on_configuration_changed'
        this.dispatch(e)
    end
}

-- register a handler for an event
function this.register(id, handler)
    -- recursive handling of ids
    if type(id) == 'table' then
        for _,n in pairs(id) do
            this.register(n, handler)
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
            log('Duplicate handler registration, skipping!')
            return
        end
    end
    -- create handler if not already created
    if #registry == 0 then
        if type(id) == 'number' and id < 0 then
            script.on_nth_tick(math.abs(id), this.dispatch)
        elseif type(id) == 'string' and bootstrap_handlers[id] then
            script[id](bootstrap_handlers[id])
        else
            script.on_event(id, this.dispatch)
        end
    end
    -- add the handler to the events table
    table.insert(registry, {handler=handler})
end

-- deregisters a handler for an event
function this.deregister(id, handler)
    -- recursive handling of ids
    if type(id) == 'table' then
        for _,n in pairs(id) do
            this.deregister(n, handler)
        end
        return
    end
    local registry = event_registry[id]
    -- error checking
    if not registry or #registry == 0 then
        log('Tried to deregister an unregistered event of id: '..id)
        return
    end
    for i,t in ipairs(registry) do
        if t.handler == handler then
            table.remove(registry, i)
        end
    end
    if #registry == 0 then
        if type(id) == 'number' and id < 0 then
            script.on_nth_tick(math.abs(id))
        elseif type(id) == 'string' and bootstrap_handlers[id] then
            script[id]()
        else
            script.on_event(id)
        end
    end
end

-- invokes all handlers for an event
-- used both by actual event handlers, and can be called manually
function this.dispatch(e)
    local id = e.name
    if e.nth_tick then
        id = -e.nth_tick
    end
    if not event_registry[id] then
        if e.input_name and event_registry[e.input_name] then
            id = e.input_name
        else
            log('ERROR: event is registered that has no handlers!')
            return
        end
    end
    for _,t in ipairs(event_registry[id]) do
        t.handler(e)
    end
end

-- shortcut for event.register('on_init', function)
function this.on_init(handler)
    this.register('on_init', handler)
end

-- shortcut for event.register('on_load', function)
function this.on_load(handler)
    this.register('on_load', handler)
end

-- shortcut for event.register('on_configuration_changed', function)
function this.on_configuration_changed(handler)
    this.register('on_configuration_changed', handler)
end

-- shortcut for event.register(-nthTick, function)
function this.on_nth_tick(nthTick, handler)
    this.register(-nthTick, handler)
end

return this