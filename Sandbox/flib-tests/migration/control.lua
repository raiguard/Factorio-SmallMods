local migration = require("__flib__.migration")

migration.run("0.1.0", {
  ["0.33.169"] = function()
    log("0.33.169")
  end,
  ["1.1.0"] = function()
    log("1.1.0")
  end,
  ["1.6.4"] = function()
    log("1.6.4")
  end,
  ["1.13.8"] = function()
    log("1.13.8")
  end,
  ["12.2.1"] = function()
    log("12.2.1")
  end,
})

migration.run("3", {
  ["1"] = function()
    log("1")
  end,
  ["5"] = function()
    log("5")
  end,
  ["6"] = function()
    log("6")
  end
})

script.on_init(function()
  local profiler = game.create_profiler()
  for _=1,1000 do
    migration.is_newer_version("1.2.3", "4.15.6")
  end
  profiler.stop()
  profiler.divide(1000)
  log(profiler)
end)