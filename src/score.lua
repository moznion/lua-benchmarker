local _M = {}
_M.__index = _M

local resolution = 1000000.0

function _M.new(real, cputime, usertime, systemtime, iters)
    return setmetatable({
        _real       = real,
        _cputime    = cputime,
        _usertime   = usertime,
        _systemtime = systemtime,
        _iters      = iters,
    }, _M)
end

function _M.get_cputime(self)
    return self._cputime
end

function _M.set_cputime(self, cputime)
    self._cputime = cputime
end

function _M.get_iters(self)
    return self._iters
end

function _M.add(self, s)
    return self.new(
        self._real       + s._real,
        self._cputime    + s._cputime,
        self._usertime   + s._usertime,
        self._systemtime + s._systemtime,
        self._iters      + s._iters
    )
end

function _M.diff(self, s)
    return self.new(
        math.max(self._real - s._real, 0),
        math.max(self._cputime - s._cputime, 0),
        math.max(self._usertime - s._usertime, 0),
        math.max(self._systemtime - s._systemtime, 0),
        self._iters
    )
end

function _M.format(self)
    local n = self._iters
    local elapsed = self._usertime + self._systemtime

    local msg = string.format(
        "%2d wallclock secs (%5.2f usr + %5.2f sys = %5.2f CPU)",
        math.floor(self._real / resolution),
        self._usertime / resolution,
        self._systemtime / resolution,
        self._cputime / resolution
    )

    if elapsed > 0 then
        msg = msg .. string.format(" @ %5.2f/s (n=%d)", n / (elapsed / resolution), n)
    end

    return msg
end

function _M.rate(self)
    local elapsed = self._usertime + self._systemtime
    return self._iters / (elapsed / resolution)
end

function _M.format_rate(self)
    local rate = self:rate()

    local format = ""
    if rate >= 100 then
        format = "%.0f"
    elseif rate >= 10 then
        format = "%.1f"
    elseif rate >= 1 then
        format = "%.2f"
    elseif rate >= 0.1 then
        format = "%.3f"
    else
        format = "%.2f"
    end

    return string.format(format .. "/s", rate)
end

function _M.equals(self, another)
    return self._real       == another._real and
           self._cputime    == another._cputime and
           self._usertime   == another._usertime and
           self._systemtime == another._systemtime and
           self._iters      == another._iters
end

return _M

