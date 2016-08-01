--#ENDPOINT get /v1/dev/{sn}/data
local sn = tostring(request.parameters.sn)
local window = tonumber(request.parameters.window) -- in minutes,if ?window=<number>
if window == nil then window = 30 end
window = tostring(window)
local qq = TSQ.q()
qq:from('wintd')
qq:where_tag_is('sn', sn)
qq:AND_time_ago(window .. "m")
qq:limit(10000)
local out = Timeseries.query({
	epoch='ms',
	q = tostring(qq)
	--q = "SELECT * FROM \"wintd\" WHERE sn = '" ..sn.."' AND time > now() - " .. window .. "m LIMIT 10000"
})
return out