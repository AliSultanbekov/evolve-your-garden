--[=[
    @class InventoryEnums
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryEnums = {
    Actions = {
        Open = "Open" :: "Open",
        Delete = "Delete" :: "Delete",
    },
    Result = {
        Success = "Success" :: "Success",
        Fail = "Fail" :: "Fail"
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(InventoryEnums) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryEnums :: Module