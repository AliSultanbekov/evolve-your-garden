--[=[
    @class ToolsConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsConfig = {}

-- [ Private Functions ] --
function ToolsConfig._Init(self: Module)
    self.DefaultToolDurabilityCost = 1
    self.DefaultWaterPerUse = 1
    self.Tools = {
        ["Watering Can"] = {
            Name = "Watering Can",
            Icon = "rbxassetid://115170506789276",
            Rarity = "Common",
            Cooldown = 0.3,
            Tags = {
                ["Watering Can"] = true,
            },
            WaterPerUse = 25,
        },
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    DefaultToolDurabilityCost: number,
    DefaultWaterPerUse: number,
    Tools: { [string]:  {
        Name: string,
        Icon: string,
        Rarity: ItemTypes.Rarity,
        Cooldown: number,
        Tags: { [string]: boolean },
        DurabilityCost: number?,
        MaxDurability: number?,
        WaterPerUse: number?,
    }},
}

export type Module = typeof(ToolsConfig) & ModuleData

(ToolsConfig :: any):_Init()

return ToolsConfig :: Module