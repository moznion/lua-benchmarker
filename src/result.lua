local _M = {}
_M.__index = _M

function _M.new(scenario_results)
    return setmetatable({
        _scenario_results = scenario_results
    }, _M)
end

function _M.timethese(self)
    print("\nScore:\n")

    for i, r in ipairs(self._scenario_results) do
        print(r.title .. ": " .. r.score:format())
    end

    return self
end

function _M.cmpthese(self)
    print("\nComparison chart:\n")

    local rows = self:create_comparision_table()
    print(self:render_table(rows))
    return self
end

function _M.create_comparision_table(self)
    local rows = {}
    local header_row = {}

    table.insert(header_row, "")
    table.insert(header_row, "Rate")
    for i, result in ipairs(self._scenario_results) do
        table.insert(header_row, result.title)
    end
    table.insert(rows, header_row)

    for i, result in ipairs(self._scenario_results) do
        local row = {}
        table.insert(row, result.title)
        table.insert(row, result.score:format_rate())

        for j, col in ipairs(self._scenario_results) do
            if col:equals(result) then
                table.insert(row, "--")
            else
                table.insert(row, string.format("%.0f%%", 100 * result.score:rate() / col.score:rate() - 100))
            end
        end

        table.insert(rows, row)
    end

    return rows
end

function _M.render_table(self, rows)
    local buff = ""
    local col_sizes = {}

    for x=1,#rows[1] do
        table.insert(col_sizes, 1)
    end

    for x=1,#rows[1] do
        for y=1,#rows do
            local row = rows[y]
            local col = row[x]
            col_sizes[x] = math.max(col_sizes[x], #col)
        end
    end

    for y=1,#rows do
        local row = rows[y]
        for x=1,#row do
            buff = buff .. string.format("  %" .. col_sizes[x] .. "s", row[x])
        end
        buff = buff .. "\n"
    end

    return buff
end

return _M

