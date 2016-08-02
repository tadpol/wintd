--#ENDPOINT get /v1/tilted
-- Gets a view window for a plot
-- Returns a history of the tilt with averages
local qq = TSQ.q():fields('MEAN(temp)'):from('wintd')
qq:where_tag_is('sn', 3):OR_tag_is('sn', 5)
qq:AND_time_ago('8h')
qq:groupby('sn'):groupbytime('15m'):fill('prev')

if request.parameters.qr ~=nil then return tostring(qq) end
local out = Timeseries.query{ epoch='s', q = tostring(qq) }
if request.parameters.raw ~= nil then return out end

if out.results[1].series == nil then
	-- ERROR
  response.code = 500
  response.message = out.message
else
	local dpwindow = {}
	local dproom = {}
	local min=9999
	local max=0
	for i, window, midish in TSQ.series_ipairs(out.results[1].series) do
		if window.mean ~= nil and midish.mean ~= nil then
			-- TODO: timezones.
			local s = os.date('%Y-%m-%d %H:%M:%S', window.time)
			local w = {}
			w.title = s
			w.value = window.mean
			dpwindow[#dpwindow + 1] = w

			local r = {}
			r.title = s
			r.value = midish.mean
			dproom[#dproom + 1] = r

			max = math.max(max, window.mean, midish.mean)
			min = math.min(min, window.mean, midish.mean)
		end
	end

	local result = {}
	result.title = "Desk Temperatures"
	result.datasequences = {}
	result.datasequences[1] = {
		title = "Window",
		datapoints = dpwindow
	}
	result.datasequences[2] = {
		title = "Room",
		datapoints = dproom
	}
	result.yAxis = {
      minValue = min-1,
      maxValue = max+1
    }
	return {graph=result}
end
-- vim: set ai sw=4 ts=4 :

