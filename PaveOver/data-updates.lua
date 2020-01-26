-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROTOTYPES

-- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

-- all 'player construct' tiles (artificial tiles) will completely remove decoratives
for _,t in pairs(data.raw['tile']) do
  if t.minable then
    t.decorative_removal_probability = 1
  end
end