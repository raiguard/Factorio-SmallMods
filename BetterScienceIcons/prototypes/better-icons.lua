-- This is contained in data-updates to allow other mods to overwrite these changes in data-final-fixes if necessary

local packs = {
    'automation-science-pack',
    'logistic-science-pack',
    'military-science-pack',
    'chemical-science-pack',
    'production-science-pack',
    'utility-science-pack',
    'space-science-pack'
}

for _,n in pairs(packs) do
    local science = data.raw['tool'][n]
    science.icon = '__BetterScienceIcons__/graphics/icons/' .. n .. '.png'
    science.icon_size = 64
    science.icon_mipmaps = 4
end