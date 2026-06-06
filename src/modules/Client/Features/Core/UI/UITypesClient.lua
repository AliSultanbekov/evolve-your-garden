--[=[
    @class UITypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Category = "Main" | "HUD" | "Misc"

export type UIInfo = {
    UIName: string,
    Category: Category,
    Conflicts: { [Category]: boolean }
}

return nil