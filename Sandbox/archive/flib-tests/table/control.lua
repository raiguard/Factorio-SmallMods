local event = require("__flib__.event")
local table = require("__flib__.table")

event.on_init(function()
  local arr = {10, 20, 30, 40, 50, 60, 70, 80, 90}

  local tbl = {
    foo = "bar",
    bar = 69,
    baz = {
      foo2 = true,
      alf = nil
    }
  }

  local tbl2 = table.deep_copy(tbl)

  local equal = table.deep_compare(tbl, tbl2)

  local merged = table.deep_merge{tbl, {
    alf = {1, 3, 5, 7, 9},
    baz = {
      alf = false
    }
  }}

  local aborted = table.for_each(arr, function(v)
    if v > 50 then
      return true
    else
      log(v)
    end
  end)

  local next_k = arr[1]
  local i = 0
  while next_k do
    i = i + 1
    log("ITERATION "..i)
    next_k = table.for_n_of(arr, next_k, 2, function(v)
      log(v)
    end)
  end

  local function filter_func(v)
    return (v / 10) % 2 == 0
  end

  local filtered = table.filter(arr, filter_func)
  local arr_filtered = table.filter(arr, filter_func, true)

  local inverted = table.invert(arr)

  local mapped = table.map(arr, function(v)
    return v * 2
  end)

  local sum = table.reduce(arr, function(acc, v) return acc + v end)
  local sum_minus_ten = table.reduce(arr, function(acc, v) return acc + v end, -10)

  local shallow_copy = table.shallow_copy(arr)
  local shallow_copy_rawset = table.shallow_copy(arr, true)

  local table_size = table.size(arr)

  local sliced = table.slice(arr, 3, 7) -- should be {30, 40, 50, 60, 70}
  local spliced = table.splice(arr, 1, 4) -- should be {10, 20, 30, 40}

  local breakpoint
end)