--#ENDPOINT get /v1/tilt
-- luacheck: globals request response (magic variables from Murano)

local window = Tsdb.query {
	tags = {sn = '3'},
	metrics = {'fahrenheit'},
	relative_start = "-30m",
	sampling_size = "15m",
	aggregate = {"avg"},
	fill = "previous",
	epoch = 's',
}
local room = Tsdb.query {
	tags = {sn = '5'},
	metrics = {'fahrenheit'},
	relative_start = "-30m",
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
	local wnd = window.values[1][2].avg or 0
	local rom = room.values[1][2].avg or 0
	return (wnd/3) - (rom/3)
	-- when >0;  window is hotter
end

-- vim: set ai sw=2 ts=2 :
