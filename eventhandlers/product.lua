--#EVENT device datapoint
-- Since various sunflowers have differnet sensors a single product definition
-- doesn't work.  So each sunflower has a single dataport that carries JSON data.
-- Then here we just reshape the JSON into the write command.
local dvs = from_json(data.value[2])
local tswq = TSW.write("wintd", {sn=data.device_sn}, dvs)

Timeseries.write({ query = tswq })

-- vim: set ai sw=4 ts=4 :
