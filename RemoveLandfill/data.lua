-- make landfill minable
local landfill = data.raw['tile']['landfill']
landfill.minable = {mining_time = 0.2, result = 'landfill'}
landfill.mined_sound = { filename = '__base__/sound/deconstruct-bricks.ogg' }
-- allow landfill and offshore pumps to be placed over shallow water
data.raw['tile']['water-shallow'].collision_mask = {'water-tile', 'item-layer', 'resource-layer'}
