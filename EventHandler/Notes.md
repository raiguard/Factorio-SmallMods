## Factorio Multi-Event Handler
Registering events through this handler allows one to easily assign multiple handlers to an event. This library also includes support for conditional events.

### Table Structures
```
static_events = {
    id = {
        {handler, filters}
    }
}
```