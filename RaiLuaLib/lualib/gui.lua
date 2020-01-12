-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event handling

-- dependencies
local event = require('lualib/event')
local util = require('__core__/lualib/util')

-- locals
local global_data
local string_split = util.split
local table_deepcopy = table.deepcopy
local table_insert = table.insert
local table_merge = util.merge

-- settings
local handlers = {}
local templates = {}

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- LOCAL UTILITIES

local function get_subtable(s, t)
  local o = table_deepcopy(t)
  for _,key in pairs(string_split(s, '%.')) do
    o = o[key]
  end
  return o
end

-- recursively load a GUI template
local function recursive_load(parent, t, output, options, parent_index)
  -- load template(s)
  if t.template then
    local template = t.template
    if type(template) == 'string' then
      template = {template}
    end
    for i=1,#template do
      t = util.merge{get_subtable(template[i], templates), t}
    end
  end
  -- format element table
  local elem_t = table_deepcopy(t)
  local style = elem_t.style
  local iterate_style = false
  if style and type(style) == 'table' then
    elem_t.style = style.name
    iterate_style = true
  end
  elem_t.children = nil
  elem_t.save_as = nil
  -- create element
  local elem = parent.add(elem_t)
  if not parent_index then parent_index = elem.index end
  -- set runtime styles
  if iterate_style then
    for k,v in pairs(t.style) do
      if k ~= 'name' then
        elem.style[k] = v
      end
    end
  end
  -- apply modifications
  if t.mods then
    for k,v in pairs(t.mods) do
      elem[k] = v
    end
  end
  -- add to output table
  if t.save_as then
    if type(t.save_as) == 'boolean' then
      t.save_as = t.handlers
    end
    output[t.save_as] = elem
  end
  -- add children
  local children = t.children
  if children then
    for i=1,#children do
      output = recursive_load(elem, children[i], output, options, parent_index)
    end
  end
  return output
end

-- -----------------------------------------------------------------------------
-- EVENTS

event.on_init(function()
  global.__lualib.gui = {}
  global_data = global.__lualib.gui
end)

event.on_load(function()
  global_data = global.__lualib.gui
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(parent, template, options)
  return recursive_load(parent, template, {}, options, options.parent_index)
end

function self.destroy(parent)
  parent.destroy()
end

function self.add_templates(...)
  local arg = {...}
  if #arg == 1 then
    for k,v in pairs(arg[1]) do
      templates[k] = v
    end
  else
    templates[arg[1]] = arg[2]
  end
  return self
end

return self