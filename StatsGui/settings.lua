local constants = require("constants")

data:extend{
  {
    type = "bool-setting",
    name = "statsgui-single-line",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a"
  }
}

for sensor_name, sensor_data in pairs(constants.sensors) do
  data:extend{
    {
      type = "bool-setting",
      name = "statsgui-show-sensor-"..sensor_name,
      setting_type = "runtime-per-user",
      default_value = true,
      order = sensor_data.order
    }
  }
end
