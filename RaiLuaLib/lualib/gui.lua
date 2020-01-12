-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event handling

-- dependencies
local event = require('lualib/event')
local util = require('__core__/lualib/util')

-- locals
local table_deepcopy = table.deepcopy
local templates = {}
local handlers = {}

local function get_template(s, initial_t)
  local template = initial_t or templates
  for _,key in pairs(util.split(s, '%.')) do
    template = template[key]
  end
  return template
end

local function recursive_load(parent, t, options)
  -- load template(s)
  if t.template then
    local template = t.template
    if type(template) == 'string' then
      template = {template}
    end
    for i=1,#template do
      t = util.merge{get_template(template[i]), t}
    end
  end
  -- format element
  local elem_t = table_deepcopy(t)
  -- style parsing
  local style = elem_t.style
  local iterate_style = false
  if style and type(style) == 'table' then
    elem_t.style = style.name
    iterate_style = true
  end
  elem_t.children = nil
  -- add element
  local elem = parent.add(elem_t)
  -- set runtime styles
  if iterate_style then
    for k,v in pairs(t.style) do
      if k ~= 'name' then
        elem.style[k] = v
      end
    end
  end
  -- add children
  local children = t.children
  if children then
    for i=1,#children do
      recursive_load(elem, children[i])
    end
  end
end

local self = {}

function self.load_templates(t)
  templates = t
  return self
end

function self.load_handlers(t)
  handlers = t
  return self
end

-- creates a GUI from the given template
function self.create(parent, template, options)
  if type(template) == 'string' then
    template = get_template(template)
  end
  recursive_load(parent, template, options)
  return parent.children
end

return self