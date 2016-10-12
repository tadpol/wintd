--#ENDPOINT get /v1/tilted
-- Gets a view window for a plot
-- Returns a history of the tilt with averages
local qq = TSQ.q():fields('MEAN(fahrenheit)'):from('window')
qq:where_tag_is('sn', 3):OR_tag_is('sn', 5)
qq:AND_time_ago('8h')
qq:groupby('sn'):groupbytime('15m'):fill('prev')

if request.parameters.qr ~=nil then return tostring(qq) end
local out = Timeseries.query{ epoch='s', q = tostring(qq) }
if request.parameters.raw ~= nil then return out end

if out.results[1].series == nil then
	-- ERROR
	response.code = 500
	response.message = {
		code=500,
		message = out.message
	}
else
	local dpwindow = {}
	local dproom = {}
	local min=9999
	local max=0
	for i, window, midish in TSQ.series_ipairs(out.results[1].series) do
		local wm = 0
		local mm = 0
		if window ~= nil and window.mean ~= nil then
			local s = os.date('%Y-%m-%d %H:%M:%S', window.time)
			local w = {}
			w.title = s
			w.value = window.mean
			wm = window.mean
			dpwindow[#dpwindow + 1] = w
		end

		if midish ~= nil and midish.mean ~= nil then
			local s = os.date('%Y-%m-%d %H:%M:%S', midish.time)
			local r = {}
			r.title = s
			r.value = midish.mean
			mm = midish.mean
			dproom[#dproom + 1] = r
		end

		max = math.max(max, wm, mm)
		min = math.min(min, wm, mm)
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
	if max == 0 then max = 78 end
	if min == 9999 then min = 70 end
	result.yAxis = {
		minValue = min-1,
		maxValue = max+1
	}
	result.type = "line"
	return {graph=result}
end
-- vim: set ai sw=2 ts=2 :

