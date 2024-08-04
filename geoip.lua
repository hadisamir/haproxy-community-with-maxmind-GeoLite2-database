-- geoip.lua
local maxminddb = require("maxminddb")

-- Path to your GeoLite2-City.mmdb file
local dbpath = "/tmp/GeoLite2-City.mmdb"

-- Open the MaxMind DB once during initialization
local db, err = maxminddb.open(dbpath)
if not db then
    core.Alert("Error opening MaxMind DB: " .. err)
    return
end

local function lookup_geoip(txn)
    local ip_address = txn.f:src()
    local result, err = db:lookup(ip_address)

    if not result then
        core.Debug("Error looking up IP: " .. err)
        txn.set_var(txn, "txn.geo_country", "N/A")
        txn.set_var(txn, "txn.geo_city", "N/A")
        txn.set_var(txn, "txn.geo_latitude", "N/A")
        txn.set_var(txn, "txn.geo_longitude", "N/A")
        return
    end

    local country_name = result:get("country", "names", "en") or "N/A"
    local city_name = result:get("city", "names", "en") or "N/A"
    local latitude = result:get("location", "latitude") or "N/A"
    local longitude = result:get("location", "longitude") or "N/A"

    txn.set_var(txn, "txn.geo_country", country_name)
    txn.set_var(txn, "txn.geo_city", city_name)
    txn.set_var(txn, "txn.geo_latitude", tostring(latitude))
    txn.set_var(txn, "txn.geo_longitude", tostring(longitude))
end

core.register_action("lookup_geoip", {"tcp-req", "http-req"}, lookup_geoip)