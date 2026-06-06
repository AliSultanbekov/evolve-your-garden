--[=[
    @class JavaBackendTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local WeatherTypesShared = require("WeatherTypesShared")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type WeatherPacket = WeatherTypesShared.Weather

export type PackStoreRefreshedPacket = {
    SaleId: PackStoreTypesShared.SaleId,
    Packs: PackStoreTypesShared.Packs,
    StartTime: number
}

return nil