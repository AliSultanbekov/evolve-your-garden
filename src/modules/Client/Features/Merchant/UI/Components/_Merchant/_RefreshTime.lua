--[=[
    @class RefreshTime
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local RefreshTime = function(props: Props)
    return Blend.New "Frame" {
        
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(RefreshTime) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return RefreshTime :: Module