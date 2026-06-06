--[=[
    @class LevelBar
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local LevelBar = function(props: Props)
    return Blend.New "Frame" {
        
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(LevelBar) & ModuleData

return LevelBar :: Module