--#ENDPOINT get /v1/diffs
-- luacheck: globals request response (magic variables from Murano)

local window = Tsdb.query {
	tags = {sn = '3'},
	metrics = {'fahrenheit'},
	limit = 2,
	sampling_size = "15m",
	aggregate = {"avg"},
	fill = "previous",
	epoch = 's',
}
local windowshade = Tsdb.query {
	tags = {sn = '7'},
	metrics = {'fahrenheit'},
	limit = 2,
	sampling_size = "15m",
	aggregate = {"avg"},
	fill = "previous",
	epoch = 's',
}
local room = Tsdb.query {
	tags = {sn = '5'},
	metrics = {'fahrenheit'},
	limit = 2,
	sampling_size = "15m",
	aggregate = {"avg"},
	fill = "previous",
	epoch = 's',
}
if request.parameters.raw ~= nil then
	return {window = window, windowshade = windowshade, room = room}
end

local function get_recent_or_nil(tbl)
	if tbl.values == nil then
		return 0
	end
	if #tbl.values == 0 then
		return 0
	end

	for _,v in ipairs(tbl.values) do
		if #v >= 2 then
			if type(v[2]) == 'table' then
				return (v[2].avg or 0)
			end
		end
	end
	return 0
end
local window_last = get_recent_or_nil(window)
local shade_last = get_recent_or_nil(windowshade)
local room_last = get_recent_or_nil(room)
if request.parameters.raws ~= nil then
	return {window = window_last, windowshade = shade_last, room = room_last}
end

return table.concat({
	" ,W,S,R",
	table.concat({'W',
		string.format('%.2f', window_last),
		string.format('%.2f', window_last - shade_last),
		string.format('%.2f', window_last - room_last)}, ','),
	table.concat({'S',
		string.format('%.2f', shade_last - window_last),
		string.format('%.2f', shade_last),
		string.format('%.2f', shade_last - room_last)}, ','),
	table.concat({'R',
		string.format('%.2f', room_last - window_last),
		string.format('%.2f', room_last - shade_last),
		string.format('%.2f', room_last)}, ','),
}, "\n")

-- vim: set ai sw=2 ts=2 :
