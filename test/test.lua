local benchmarker = require 'benchmarker'

local b = benchmarker.new({
    ["insert append"] = function ()
        local arr = {}
        for i=1,1000 do
            table.insert(arr, i)
        end
    end,
    ["index append"] = function ()
        local arr = {}
        for i=1,1000 do
            arr[i] = i
        end
    end,
})

b:warmup(1):run(1):timethese():cmpthese()
b:warmup(1):run_within_time(0.1):timethese():cmpthese()

local r, err = b:run_within_time(0.09)
assert(r == nil, "when given time limit is less than minimum")
assert(err ~= nil, "when given time limit is less than minimum")

print("OK")

