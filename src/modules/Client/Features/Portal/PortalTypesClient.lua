local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[=[
    @class PortalTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type PortalId = string
export type PortalModel = typeof(ReplicatedStorage.TypeExamples.Portal)
export type Portal = {
    Whitelist: { [string]: boolean },
    Id: PortalId,
    Model: PortalModel,
    Maid: Maid.Maid, 
    Target: ValueObject.ValueObject<string?>
}
export type Portals = ObservableMap.ObservableMap<PortalId, Portal>

return nil