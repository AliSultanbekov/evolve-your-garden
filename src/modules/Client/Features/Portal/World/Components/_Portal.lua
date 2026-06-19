--[=[
    @class Portal
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local PortalTypesClient = require("PortalTypesClient")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Portal = function(props: Props)
    local MaidObject = Maid.new()

    local Model = MaidObject:Add(props.Model)

    return MaidObject
end

-- [ Types ] --
type Props = {
    Model: PortalTypesClient.PortalModel
}
type ModuleData = {}

export type Module = typeof(Portal) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Portal :: Module