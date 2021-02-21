local misc = require("__flib__.misc")

local constants = require("constants")

-- code based on "improved research queue" by sonaxaton
-- https://github.com/dbeckwith/factorio-research-queue/blob/af6404ab696502a86eec40a4baf7fe00d0c714c7/control.lua#L316
return function(player)
  if not global.players[player.index].settings.show_research then return end

  local force = player.force
  local tech = force.current_research
  if tech then
    -- retrieve or create progress samples table
    local progress_samples = global.research_progress_samples[force.index]
    if not progress_samples then
      progress_samples = {}
    global.research_progress_samples[force.index] = progress_samples
    end
    progress_samples[#progress_samples + 1] = {tech = tech.name, progress = force.research_progress}
    if #progress_samples > constants.research_progress_samples_count then
      table.remove(progress_samples, 1)
    end

    local estimated_ticks = 0
    if #progress_samples > 1 then
      local num_samples = 0
      for i = 2, #progress_samples do
        local previous_sample = progress_samples[i - 1]
        local current_sample = progress_samples[i]
        if previous_sample.tech == current_sample.tech then
          -- how much the progress increased per tick
          local speed = (current_sample.progress - previous_sample.progress) / 60
          -- don't add if the speed is negative for whatever reason
          if speed > 0 then
            -- how many ticks left until the research is finished
            estimated_ticks = estimated_ticks + ((1 - current_sample.progress) / speed)
            num_samples = num_samples + 1
          end
        end
      end
      -- rolling average
      if num_samples > 0 then
        estimated_ticks = estimated_ticks / num_samples
      end
    end

    return {"", {"statsgui.research-finished"}, " = ", misc.ticks_to_timestring(estimated_ticks)}
  end
end

