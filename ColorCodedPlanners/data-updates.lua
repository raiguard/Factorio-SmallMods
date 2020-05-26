local changes = {
  ["blueprint"] = {
    ["blueprint"] = {
      selection_color = {r=0, g=0.5, b=1},
      alt_selection_color = {r=0, g=1, b=1},
      selection_cursor_box_type = "electricity",
      alt_selection_cursor_box_type = "electricity"
    }
  },
  ["copy-paste-tool"] = {
    ["cut-paste-tool"] = {
      selection_color = {r=1, g=0, b=0},
      alt_selection_color = {r=1, g=0, b=0.75},
      selection_cursor_box_type = "not-allowed",
      alt_selection_cursor_box_type = "not-allowed"
    },
    ["copy-paste-tool"] = {
      selection_color = {r=0, g=0.5, b=1},
      alt_selection_color = {r=0, g=1, b=1},
      selection_cursor_box_type = "electricity",
      alt_selection_cursor_box_type = "electricity"
    }
  },
  ["deconstruction-item"] = {
    ["deconstruction-planner"] = {
      selection_color = {r=1, g=0, b=0},
      alt_selection_color = {r=1, g=0, b=0.75},
      selection_cursor_box_type = "not-allowed",
      alt_selection_cursor_box_type = "not-allowed"
    }
  },
  ["upgrade-item"] = {
    ["upgrade-planner"] = {
      selection_color = {r=0, g=1, b=0},
      alt_selection_color = {r=0.75, g=1, b=0},
      selection_cursor_box_type = "copy",
      alt_selection_cursor_box_type = "copy"
    }
  }
}

for category, items in pairs(changes) do
  local category_data = data.raw[category]
  for name, mods in pairs(items) do
    local item = category_data[name]
    for k, v in pairs(mods) do
      item[k] = v
    end
  end
end

data.raw["utility-sprites"]["default"]["upgrade_mark"].filename = "__ColorCodedPlanners__/graphics/upgrade.png"