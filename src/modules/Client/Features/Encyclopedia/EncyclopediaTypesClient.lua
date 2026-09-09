--[=[
    @class EncyclopediaTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ReactiveDiscoveredItem = {
    DiscoveredTime: ValueObject.ValueObject<number?>,
    TotalAcquired: ValueObject.ValueObject<number>,
}

return nil