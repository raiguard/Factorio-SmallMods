data.raw["rocket-silo"]["rocket-silo"].fixed_recipe = nil
data.raw["rocket-silo"]["rocket-silo"].rocket_result_inventory_size = 5
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].inventory_size = 5
data.raw["tool"]["space-science-pack"].rocket_launch_product = nil
data.raw["tool"]["space-science-pack"].rocket_launch_products = {
  {"raw-fish", 100},
  {"uranium-235", 50}
}
data.raw["recipe"]["rocket-part"].hidden = false

data:extend{
  {
    type = "recipe",
    name = "rocket-part-alt",
    energy_required = 1,
    enabled = true,
    hidden = false,
    category = "rocket-building",
    ingredients = {
      {"raw-fish", 10}
    },
    result= "grenade"
  }
}

data.raw["assembling-machine"]["assembling-machine-1"].fixed_recipe = "automation-science-pack"

data.raw["recipe"]["uranium-processing"].results = {
  {type="item", name="uranium-235", amount=1, probability=0.007},
  {type="item", name="uranium-238", amount_min=1, amount_max=3, probability=0.993}
}

data.raw["rocket-silo"]["rocket-silo"].crafting_categories = {"crafting", "rocket-building"}