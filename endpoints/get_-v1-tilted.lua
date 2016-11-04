--#ENDPOINT get /v1/tilted
-- luacheck: globals request response (magic variables from Murano)
-- Gets a view window for a plot
-- Returns a history of the tilt with averages

local window = Tsdb.query {
	tags = {sn = '3'},
	metrics = {'fahrenheit'},
	relative_start = "-8h",
	sampling_size = "15m",
	aggregate = {"avg"},
	fill = "previous",
	epoch = 's',
}
local room = Tsdb.query {
	tags = {sn = '5'},
	metrics = {'fahrenheit'},
	relative_start = "-8h",
	sampling_size = "15m",
	aggregate = {"avg"},
	fill = "previous",
	epoch = 's',
}
if request.parameters.raw ~= nil then return {window = window, room = room} end


if window.error ~= nil then
	-- ERROR
	response.code = 500
	response.message = {
		code=500,
		message = window
	}
elseif room.error ~= nil then
	response.code = 500
	response.message = {
		code=500,
		message = room
	}
else
	local min=9999
	local max=0

	local function tsbd_result_to_plot(out)
		local resulting = {}
		for _, entry in ipairs(out.values) do
			local s = os.date('%Y-%m-%d %H:%M:%S', entry[1])
			if type(entry[2]) == 'table' and type(entry[2].avg) == 'number' then
				local w = {}
				w.title = s
				w.value = entry[2].avg
				resulting[#resulting + 1] = w
				max = math.max(max, w.value)
				min = math.min(min, w.value)
			end
		end
		return resulting
	end

	local dpwindow = tsbd_result_to_plot(window)
	local dproom = tsbd_result_to_plot(room)

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

