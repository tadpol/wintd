--#EVENT device datapoint
-- luacheck: globals data (magic variable from Murano)
-- Since various sunflowers have differnet sensors a single product definition
-- doesn't work.  So each sunflower has a single dataport that carries JSON data.
-- Then here we just reshape the JSON into the write command.

Keystore.command{
	key="last." .. tostring(data.device_sn),
	command='lpush',
	args={to_json(data)}
}
Keystore.command{
	key="last." .. tostring(data.device_sn),
	command='ltrim',
	args={0, 10}
}

local dvs, err = from_json(data.value[2])
if dvs ~= nil then
	dvs.sern = nil
	dvs.sn = nil
	local dvn = {}
	for k,v in pairs(dvs) do
		local g = tonumber(v)
		if g ~= nil then
			dvn[k] = g
		else
			dvn[k] = v
		end
	end
	local tswq = TSW.write("window", {sn=data.device_sn}, dvs)
	Timeseries.write({ query = tswq })

	Tsdb.write{
		tags = {sn = data.device_sn},
		metrics = dvn,
	}
else
	Keystore.set{key="err." .. tostring(data.device_sn), value = err}
end

-- vim: set ai sw=2 ts=2 :
