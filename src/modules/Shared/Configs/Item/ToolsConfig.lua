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
    self.Tools = {
        ["Watering Can"] = {
            Name = "Watering Can",
            Icon = "rbxassetid://115170506789276",
            Rarity = "Common",
            Cooldown = 10,
            Tags = {},
        },
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    DefaultToolDurabilityCost: number,
    Tools: { [string]:  {
        Name: string,
        Icon: string,
        Rarity: ItemTypes.Rarity,
        Cooldown: number,
        Tags: { [string]: boolean },
        DurabilityCost: number?,
        MaxDurability: number?,
    }},
}

export type Module = typeof(ToolsConfig) & ModuleData

(ToolsConfig :: any):_Init()

return ToolsConfig :: Module