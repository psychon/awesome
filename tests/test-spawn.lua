--- Tests for spawn

local util = require("awful.util")

local spawns_done = 0

local steps = {
  function(count)
    if count == 1 then
      local steps_yay = 0
      util.spawn_with_lines("echo yay", function(line)
        assert(line == "yay", "line == '" .. tostring(line) .. "'")
        assert(steps_yay == 0)
        steps_yay = steps_yay + 1
      end, function()
        assert(steps_yay == 1)
        steps_yay = steps_yay + 1
        spawns_done = spawns_done + 1
      end)

      local steps_count = 0
      util.spawn_with_lines({ "sh", "-c", "printf line1\\\\nline2\\\\nline3" },
      function(line)
        assert(steps_count < 3)
        steps_count = steps_count + 1
        assert(line == "line" .. steps_count, "line == '" .. tostring(line) .. "'")
      end, function()
        assert(steps_count == 3)
        steps_count = steps_count + 1
        spawns_done = spawns_done + 1
      end)
    end
    if spawns_done == 2 then
      return true
    end
  end,
}

require("_runner").run_steps(steps)
