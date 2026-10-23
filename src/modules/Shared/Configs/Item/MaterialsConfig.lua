--[=[
    @class MaterialsConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MaterialsConfig = {}

-- [ Private Functions ] --
function MaterialsConfig._Init(self: Module)
    self.Materials = {
        ["Fruit"] = {
            Name = "Fruit",
            Icon = "rbxassetid://115748294366089",
            Rarity = "Common"
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type MaterialEntry = {
    Name: string,
    Icon: string,
    Rarity: ItemTypes.Rarity,
}

type ModuleData = {
    Materials: { [string]: MaterialEntry },
}

export type Module = typeof(MaterialsConfig) & ModuleData

(MaterialsConfig :: any):_Init()

return MaterialsConfig :: Module
