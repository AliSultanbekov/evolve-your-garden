--[=[
    @class WeatherTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Weather = {
    Name: string,
    Duration: number,
    StartTime: number,
}

export type WeatherSelectedRemotePacket = {
    Weather: Weather
}

export type GetCurrentWeatherRemotePacket = {
    Weather: Weather
}

return nil