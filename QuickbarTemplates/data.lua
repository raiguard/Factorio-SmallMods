-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICKBAR TEMPLATES PROTOTYPES

-- -----------------------------------------------------------------------------
-- SPRITES

data:extend{
  {
    type = 'sprite',
    name = 'qt-export-blueprint-white',
    filename = '__QuickbarTemplates__/graphics/icons/export-blueprint-x32-white.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'qt-import-blueprint-white',
    filename = '__QuickbarTemplates__/graphics/icons/import-blueprint-x32-white.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  }
}

-- DEBUGGING TOOL
if mods['debugadapter'] then
  data:extend{
    {
      type = 'custom-input',
      name = 'DEBUG-INSPECT-GLOBAL',
      key_sequence = 'CONTROL + SHIFT + ENTER'
    }
  }
end