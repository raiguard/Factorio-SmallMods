local constants = {}

constants.research_progress_samples_count = 3

constants.builtin_sensors = {
  {name = "research", enabled = true, order = "b"},
  {name = "evolution", enabled = true, order = "c"},
  {name = "pollution", enabled = false, order = "d"},
  {name = "playtime", enabled = true, order = "e"},
  {name = "daytime", enabled = true, order = "f"}
}

return constants
