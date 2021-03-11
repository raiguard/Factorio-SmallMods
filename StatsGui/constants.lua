local constants = {}

constants.builtin_sensors = {
  {name = "research", enabled = true, order = "ba"},
  {name = "evolution", enabled = true, order = "bb"},
  {name = "pollution", enabled = false, order = "bc"},
  {name = "playtime", enabled = true, order = "bd"},
  {name = "daytime", enabled = true, order = "be"}
}

constants.interface_version = 1

constants.research_progress_samples_count = 3

return constants
