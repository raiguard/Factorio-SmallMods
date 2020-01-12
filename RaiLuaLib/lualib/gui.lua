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

local function get_subtable(s, t)
  for _,key in pairs(util.split(s, '%.')) do
    t = t[key]
  end
  return t
end

local function recursive_load(parent, t, output_table, options)
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
  elem_t.handlers = nil
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
  -- register handler(s)
  if t.handlers then
    local index = elem.index
    local pi = options.player_index or error('Must specify a player index for GUI handlers in the options table!')
    if type(t.handlers) == 'string' then
      t.handlers = get_subtable(t.handlers, handlers)
    end
    for n,func in pairs(t.handlers) do
      local nn = n:gsub('on_', 'on_gui_')
      if type(func) == 'string' then
        func = get_subtable(func, handlers)
      end
      event[nn](func, {name=index..'_'..n, player_index=pi, gui_filters=index})
    end
  end
  -- add children
  local children = t.children
  if children then
    for i=1,#children do
      output_table = recursive_load(elem, children[i], output_table, options)
    end
  end
  return output_table
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
    template = get_subtable(template, templates)
  end
  return recursive_load(parent, template, {}, options)
end

return self