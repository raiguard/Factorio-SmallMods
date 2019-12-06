-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICKBAR TEMPLATES PROTOTYPES

-- -----------------------------------------------------------------------------
-- ENTITIES

local chest = table.deepcopy(data.raw['container']['wooden-chest'])
chest.name = 'quickbar-blueprint-chest'
chest.subgroup = 'other'
chest.order = 'zzzzzzzz'
chest.collision_mask = {'layer-15'}
chest.selection_box = nil
chest.picture = {
    filename = '__core__/graphics/empty.png',
    priority = 'very-low',
    width = 1,
    height = 1,
    frame_count = 1
}
chest.inventory_size = 1
data:extend{chest}

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