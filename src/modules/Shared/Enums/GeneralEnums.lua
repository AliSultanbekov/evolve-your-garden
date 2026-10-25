--[=[
    @class GeneralEnums
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GeneralEnums = {
    Result = {
        Success = "Success" :: "Success",
        Fail = "Fail" :: "Fail"
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(GeneralEnums) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GeneralEnums :: Module
