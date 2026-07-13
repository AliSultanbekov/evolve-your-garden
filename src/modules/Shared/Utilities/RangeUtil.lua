--[=[
    @class RangeUtil
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local RangeUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(RangeUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function RangeUtil.CheckModelRange(self: Module, model1: Model, model2: Model, range: number)
    local P1 = model1:GetPivot().Position
    local P2 = model2:GetPivot().Position
    
    local Distance = (P1 - P2).Magnitude

    if Distance <= range then
        return true
    end

    return false
end

return RangeUtil :: Module