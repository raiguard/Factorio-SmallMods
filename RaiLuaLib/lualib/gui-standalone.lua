-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE - STANDALONE VERSION
-- GUI templating. Does not deal with event registration at all

-- dependencies
local util = require('__core__/lualib/util')

-- locals
local string_split = util.split
local table_deepcopy = table.deepcopy

-- settings
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
local function recursive_load(parent, t, output)
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
  local elem
  -- skip all of this if it's a tab-and-content
  if t.type ~= 'tab-and-content' then
    -- format element table
    local elem_t = table_deepcopy(t)
    local style = elem_t.style
    local iterate_style = false
    if style and type(style) == 'table' then
      elem_t.style = style.name
      iterate_style = true
    end
    elem_t.children = nil
    -- create element
    elem = parent.add(elem_t)
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
        output = recursive_load(elem, children[i], output)
      end
    end
  else
    local tab, content
    output, tab = recursive_load(parent, t.tab, output)
    output, content = recursive_load(parent, t.content, output)
    parent.add_tab(tab, content)
  end
  return output, elem
end

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(parent, template)
  build_data = {}
  return recursive_load(parent, template, {})
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