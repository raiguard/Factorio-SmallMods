pcall(require,'__debugadapter__/debugadapter.lua')

local function setup_player(player)
  global.players[player.index] = {}
end

script.on_init(function()
  global.players = {}
  for i,p in pairs(game.players) do
    setup_player(p)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  setup_player(game.get_player(e.player_index))
end)

local types = {
  ['pipe'] = true,
  ['pipe-to-ground'] = true,
  ['storage-tank'] = true,
  ['infinity-pipe'] = true,
  ['pump'] = true
}

script.on_event('rt-relocate-fluid', function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local selected = player.selected
  if selected and selected.valid and types[selected.type] then
    if not player_table.fluid_relocate then
      -- set up relocation
      player_table.fluid_relocate = {
        source = selected,
        highlight_box = player.surface.create_entity{
          name = 'highlight-box',
          position = selected.position,
          bounding_box = selected.selection_box,
          box_type = 'pair',
          render_player_index = e.player_index,
          blink_interval = 30
        }
      }
    else
      -- relocate fluid
      -- for now we only support one fluidbox, might do more in the future
      local data = player_table.fluid_relocate
      if data.source.name == selected.name then
        selected.fluidbox[1] = data.source.fluidbox[1]
        data.source.fluidbox[1] = nil
        goto delete_data
      else
        goto invalid
      end
    end
  elseif player_table.fluid_relocate then
    goto invalid
  end
  goto complete
  ::invalid::
  player.print{'rt-chat-message.invalid-target'}
  ::delete_data::
  local data = player_table.fluid_relocate
  data.highlight_box.destroy()
  player_table.fluid_relocate = nil
  ::complete::
end)

-- DEBUGGING
if __DebugAdapter then
  script.on_event('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end