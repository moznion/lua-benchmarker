local benchmarker = require "benchmarker"

benchmarker.new({
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
}):warmup(10):run(10000):timethese():cmpthese()

