--#ENDPOINT get /v1/current/{dev}
local dev = tostring(request.parameters.dev)
local qq = TSQ.q():fields('temp'):from('wintd')
if dev == "window" then
	qq:where_tag_is('sn', 3)
else
	qq:where_tag_is('sn', 5)
end
qq:AND_time_ago('1h')
qq:limit(100)

if request.parameters.qr ~=nil then return tostring(qq) end
local out = Timeseries.query{ epoch='ms', q = tostring(qq) }
if request.parameters.raw ~= nil then return out end

if out.results[1].series == nil then
	-- ERROR
  response.code = 500
  response.message = out.message
else
	for i, temps in TSQ.series_ipairs(out.results[1].series) do
		if temps.mean ~= nil then
			return temps.mean
		end
	end
	return 0.0
end

-- vim: set ai sw=4 ts=4 :