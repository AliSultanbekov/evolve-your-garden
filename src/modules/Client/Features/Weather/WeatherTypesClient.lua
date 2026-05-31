--[=[
    @class WeatherTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local WeatherTypesShared = require("WeatherTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type WeatherProps = {
    Weather: WeatherTypesShared.Weather
}

return nil