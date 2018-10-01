local _M = {}
_M.__index = _M

function _M.new(title, score)
    return setmetatable({
        title = title,
        score = score
    }, _M)
end

function _M.format(self)
    return "Result [title=" .. self.title .. ", score=" .. self.score .. "]"
end

function _M.equals(self, another)
    return self.title == another.title and
           self.score:equals(another.score)
end

return _M

