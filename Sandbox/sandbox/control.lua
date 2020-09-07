local function register_overrides()
  remote.call("CursorEnhancements", "add_overrides", {
    ["medium-electric-pole"] = "big-electric-pole",
    ["big-electric-pole"] = "substation"
  })
end
script.on_init(register_overrides)
script.on_load(register_overrides)