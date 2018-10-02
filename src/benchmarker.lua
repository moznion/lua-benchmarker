local cputime = require 'cputime'
local hires_time = require 'hires_time'

local score_class = require 'benchmarker.score'
local result_class = require 'benchmarker.result'
local scenario_result_class = require 'benchmarker.scenario_result'

local _M = {}
_M.__index = _M

local resolution = 1000000.0

function _M.new(functions)
    return setmetatable({
        _functions = functions,
        _debug_mode = false,
        _empty_loop_cache = {},
    }, _M)
end

function _M._debug(self, msg)
    if self._debug_mode then
        print("[DEBUG] " .. msg)
    end
end

function _M.enable_debug_mode(self)
    self._debug_mode = true
    return self
end

function _M.warmup(self, ntimes)
    print("starting warming up: " .. ntimes)

    for label, func in pairs(self._functions) do
        for i=1,ntimes do
            func()
        end
    end

    self:_debug("finished warming up")

    return self
end

function _M._measure_empty_loop(self, ntimes)
    if not self._empty_loop_cache[ntimes] then
        local empty = self:_runloop(ntimes, function() end)
        self._empty_loop_cache[ntimes] = empty
        return empty
    end

    self:_debug("hit empty loop cache")
    return self._empty_loop_cache[ntimes]
end

function _M.run(self, ntimes)
    local results = {}
    local i = 1
    for label, func in pairs(self._functions) do
        local score = self:timeit(ntimes, func)
        results[i] = scenario_result_class.new(label, score)
        i = i + 1
    end

    return result_class.new(results)
end

function _M.run_by_time(self, d)
    local results = {}
    local i = 1
    for label, func in pairs(self._functions) do
        self:_debug('running ' .. label)
        local score, err = self:countit(d, func)
        if err ~= nil then
            self:_debug('error: ' .. err)
            return nil, err
        end
        results[i] = scenario_result_class.new(label, score)
        i = i + 1
    end

    return result_class.new(results), nil
end

function _M.clear_all_cache(self)
    self._empty_loop_cache = {}
end

function _M.clear_cache(self, ntimes)
    self._empty_loop_cache[ntimes] = nil
end

function _M.timeit(self, ntimes, func)
    local empty_score = self:_measure_empty_loop(ntimes)
    local score = self:_runloop(ntimes, func)

    return score:diff(empty_score)
end

function _M.countit(self, tmax, func)
    if tmax < 0.1 then
        return nil, "timelimit cannot be less than 0.1"
    end

    local zeros = 0
    local n = 1
    local tc = 0.0

    while true do
        self:_debug('finding minumum n: ' .. n)

        local td = self:timeit(n, func)
        tc = td:get_cputime() / resolution

        self:_debug(string.format('TC: %.8f', tc))

        if tc <= 0.01 and n > 1024 then
            zeros = zeros + 1
            if zeros > 16 then
                return nil, "timing is consistently zero in estimation loop, cannot benchmark. N=" .. n
            end
        else
            zeros = 0
        end

        if tc > 0.1 then
            break
        end

        if n < 0 then
            return nil, "overflow?"
        end

        n = n * 2
    end

    local nmin = n
    -- Get $n high enough that we can guess the final $n with some accuracy.
    local tpra = 0.1 * tmax -- Target/time practice
    while tc < tpra do
        -- The 5% fudge is to keep us from iterating again all # that
        -- often (this speeds overall responsiveness when $tmax is big # and
        -- we guess a little low). This does not noticeably affect #
        -- accuracy since we're not counting these times.
        n = math.floor(tpra * 1.05 * n / tc) -- Linear approximation
        local td = self:timeit(n, func)
        local new_tc = td:get_cputime() / resolution
        -- Make sure we are making progress.
        if new_tc > 1.2 * tc then
            tc = new_tc
        else
            tc = 1.2 * tc
        end
    end

    -- Now, do the 'for real' timing(s), repeating until we exceed the max
    local result = score_class.new(0, 0, 0, 0, 0)

    -- The 5% fudge is because $n is often a few % low even for routines
    -- with stable times and avoiding extra timeit()s is nice for
    -- accuracy's sake.
    n = math.floor(n * (1.05 * tmax / tc))
    zeros = 0
    while true do
        local td = self:timeit(n, func)
        result = result:add(td)
        if result:get_cputime() / resolution >= tmax then
            break
        end

        if result:get_cputime() == 0 then
            zeros = zeros + 1
            if zeros > 16 then
                return nil, "timing is consistently zero in estimation loop, cannot benchmark. N=" .. n
            end
        else
            zeros = 0
        end

        if result:get_cputime() < 10000 then
            result:set_cputime(10000)
        end

        local r = tmax / (result:get_cputime() / resolution) - 1 -- Linear
        -- approximation
        n = math.floor(r * result:get_iters())
        if n < nmin then
            n = nmin
        end
    end

    return result, nil
end

function _M._runloop(self, ntimes, func)
    local real1 = hires_time.get_epoch_micros()
    local cputime1 = self:_get_cpu_time()
    local usertime1 = self:_get_cpu_user_time()
    local systemtime1 = self:_get_cpu_system_time()

    for i=0,ntimes do
        func()
    end

    local real2 = hires_time.get_epoch_micros()
    local cputime2 = self:_get_cpu_time()
    local usertime2 = self:_get_cpu_user_time()
    local systemtime2 = self:_get_cpu_system_time()

    return score_class.new(
        real2 - real1,
        cputime2 - cputime1,
        usertime2 - usertime1,
        systemtime2 - systemtime1,
        ntimes
    )
end

function _M._get_cpu_time()
    local utime, stime, err = cputime.get_process_cputime()
    if err ~= nil then
        return nil, err
    end
    return utime + stime, nil
end

function _M._get_cpu_user_time()
    local utime, stime, err = cputime.get_process_cputime()
    return utime, err
end

function _M._get_cpu_system_time()
    local utime, stime, err = cputime.get_process_cputime()
    return stime, err
end

return _M

