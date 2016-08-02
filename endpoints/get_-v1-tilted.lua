--#ENDPOINT get /v1/tilted
-- Gets a view window for a plot
-- Returns a history of the tilt with averages
local qq = TSQ.q():fields('MEAN(temp)'):from('wintd')
qq:where_tag_is('sn', 3):OR_tag_is('sn', 5)
qq:AND_time_ago('8h')
qq:groupby('sn'):groupbytime('15m'):fill('prev')

if request.parameters.qr ~=nil then return tostring(qq) end
local out = Timeseries.query{ epoch='ms', q = tostring(qq) }
if request.parameters.raw ~= nil then return out end

if out.results[1].series == nil then
	-- ERROR
  response.code = 500
  response.message = out.message
else
	local result = {}
	for i, window, midish in TSQ.series_ipairs(out.results[1].series) do
		if window.mean ~= nil and midish.mean ~= nil then
			local s = tostring(window.time)
			s = s .. "," .. tostring(window.mean - midish.mean)
			s = s .. "," .. window.mean
			s = s .. "," .. midish.mean
			result[#result + 1] = s
		end
	end
	return table.concat(result, "\n") .. "\n\n"
end
-- vim: set ai sw=4 ts=4 :

