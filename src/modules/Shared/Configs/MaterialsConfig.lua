--[=[
    @class MaterialsConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MaterialsConfig = {
    Materials = {
        ["Snow Blossom Fruit"] = {
            Name = "Snow Blossom Fruit",
            Rarity = "Common"
        }
    }
} :: {
    Materials: {
        [string]: {
            Name: string,
            Rarity: string
        }
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(MaterialsConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return MaterialsConfig :: Module