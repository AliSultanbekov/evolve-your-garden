--[=[
    @class UIConfig
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

--[[
    Conficts = {
        uigroup closes: uigroups
    }
]]
local UIConfig = {
    Conflicts = {
        ["Primary"] = { 
            ["Primary"] = true
        },
        ["HUD"] = {}
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(UIConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return UIConfig :: Module