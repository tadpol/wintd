--#ENDPOINT get /v1/tilt
local qq = TSQ.q():fields('MEAN(temp)'):from('wintd')
qq:where_tag_is('sn', 3):OR_tag_is('sn', 5)
qq:AND_time_ago('1h')
qq:groupby('sn'):groupbytime('15m'):fill('prev'):limit(3)
local out = Timeseries.query{ epoch='ms', q = tostring(qq) }

if out.results[1].series == nil then
	-- ERROR
  response.code = 500
  response.message = out.message
else
	local wnd, msh = 0, 0
	for i, window, midish in TSQ.series_ipairs(out.results[1].series) do
		wnd = wnd + window.mean
		msh = msh + midish.mean
	end
	return (wnd/3) - (msh/3)
	-- when >0;  window is hotter
end