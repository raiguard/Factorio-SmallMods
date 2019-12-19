local naked_subelements = {'ties', 'stone_path', 'stone_path_background'}
local straight_ref = {
    prefix = '__InsetRails__/graphics/entity/straight-rail/',
    nakedify_pictures = {
        {'straight_rail_horizontal', 'straight-rail-horizontal'},
        {'straight_rail_vertical', 'straight-rail-vertical'},
        {'straight_rail_diagonal_left_top', 'straight-rail-diagonal'},
        {'straight_rail_diagonal_right_top', 'straight-rail-diagonal'},
        {'straight_rail_diagonal_right_bottom', 'straight-rail-diagonal'},
        {'straight_rail_diagonal_left_bottom', 'straight-rail-diagonal'}
    },
    adjustments = {
        straight_rail_horizontal = {
            backplates = {0,-0.08}
        },
        -- straight_rail_vertical = {
        --     backplates = {0.08,0}
        -- },
        straight_rail_diagonal_left_top = {
            backplates = {-0.01,-0.01}
        },
        straight_rail_diagonal_right_bottom = {
            backplates = {-0.01,-0.01}
        }
    }
}
local curved_ref = {
    prefix = '__InsetRails__/graphics/entity/curved-rail/',
    nakedify_pictures = {
        {'curved_rail_vertical_left_top', 'curved-rail-vertical'},
        {'curved_rail_vertical_right_top', 'curved-rail-vertical'},
        {'curved_rail_vertical_right_bottom', 'curved-rail-vertical'},
        {'curved_rail_vertical_left_bottom', 'curved-rail-vertical'},
        {'curved_rail_horizontal_left_top', 'curved-rail-horizontal'},
        {'curved_rail_horizontal_right_top', 'curved-rail-horizontal'},
        {'curved_rail_horizontal_right_bottom', 'curved-rail-horizontal'},
        {'curved_rail_horizontal_left_bottom', 'curved-rail-horizontal'}
    },
    adjustments = {
        curved_rail_horizontal_left_top = {
            backplates = {0,-0.01}
        }
    }
}
local function inset(rail, ref)
    -- nakedify
    for _,id in ipairs(ref.nakedify_pictures) do
        for _,element in ipairs(naked_subelements) do
            local obj = rail.pictures[id[1]][element]
            obj.filename = string.format(ref.prefix..'%s-transparent.png', id[2])
            obj.hr_version.filename = string.format(ref.prefix..'hr-%s-transparent.png', id[2])
        end
    end
    rail.pictures['rail_endings'].sheets[1].filename = '__InsetRails__/graphics/entity/rail-endings/rail-endings-transparent.png'
    rail.pictures['rail_endings'].sheets[1].hr_version.filename = '__InsetRails__/graphics/entity/rail-endings/hr-rail-endings-transparent.png'
    -- adjust sprites
    for pic,list in pairs(ref.adjustments) do
        for n,shift in pairs(list) do
            rail.pictures[pic][n].shift = shift
            rail.pictures[pic][n].hr_version.shift = shift
        end
    end
end

-- item (for now)
local planner = table.deepcopy(data.raw["rail-planner"]["rail"])
planner.name = "inset-rail"
planner.order = "a[train-system]-a[train]-z"
planner.place_result = "inset-straight-rail"
planner.straight_rail = "inset-straight-rail"
planner.curved_rail = "inset-curved-rail"
-- straight
local straight_rail = table.deepcopy(data.raw['straight-rail']['straight-rail'])
straight_rail.name = 'inset-straight-rail'
straight_rail.order = 'a'
inset(straight_rail, straight_ref)
-- curved
local curved_rail = table.deepcopy(data.raw['curved-rail']['curved-rail'])
curved_rail.name = 'inset-curved-rail'
curved_rail.order = 'a'
inset(curved_rail, curved_ref)

data:extend{planner, straight_rail, curved_rail}

