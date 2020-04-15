local version_format_string = "%003d.%003d.%003d"
local version_pattern_string = "(%d+).(%d+).(%d+)"
local format = string.format
local match = string.match

local function is_newer_version(version1, version2)
  local v1, v2 = nil
  v1 = format(version_format_string, match(version1, version_pattern_string))
  v2 = format(version_format_string, match(version2, version_pattern_string))
  if v1 and v2 then
    if v2 > v1 then return true end
    return false
  end
  return nil
end

local string_split = require("__core__.lualib.util").split

-- returns true if v2 is newer than v1, false if otherwise
local function compare_versions(v1, v2)
  local v1_split = string_split(v1, ".")
  local v2_split = string_split(v2, ".")
  for i=1,#v1_split do
    if v1_split[i] < v2_split[i] then
      return true
    elseif v1_split[i] > v2_split[i] then
      return false
    end
  end
  return false
end

script.on_init(function()
  local profiler = game.create_profiler()
  for _=1,100000 do
    is_newer_version("1.1.4", "1.2.1")
  end
  profiler.stop()
  profiler.divide(100000)
  log(profiler)

  profiler.reset()
  for _=1,100000 do
    compare_versions("1.1.4", "1.2.1")
  end
  profiler.stop()
  profiler.divide(100000)
  log(profiler)
end)