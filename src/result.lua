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

    local header_row_cursor = 1
    header_row[header_row_cursor] = ""
    header_row_cursor = header_row_cursor + 1
    header_row[header_row_cursor] = "Rate"
    header_row_cursor = header_row_cursor + 1

    for i, result in ipairs(self._scenario_results) do
        header_row[header_row_cursor] = result.title
        header_row_cursor = header_row_cursor + 1
    end

    local rows_cursor = 1
    rows[rows_cursor] = header_row
    rows_cursor = rows_cursor + 1

    for i, result in ipairs(self._scenario_results) do
        local row = {}
        local row_cursor = 1

        row[row_cursor] = result.title
        row_cursor = row_cursor + 1
        row[row_cursor] = result.score:format_rate()
        row_cursor = row_cursor + 1

        for j, col in ipairs(self._scenario_results) do
            if col:equals(result) then
                row[row_cursor] = "--"
            else
                row[row_cursor] = string.format("%.0f%%", 100 * result.score:rate() / col.score:rate() - 100)
            end
            row_cursor = row_cursor + 1
        end

        rows[rows_cursor] = row
        rows_cursor = rows_cursor + 1
    end

    return rows
end

function _M.render_table(self, rows)
    local buff = ""
    local col_sizes = {}

    for x=1,#rows[1] do
        col_sizes[x] = 1

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

