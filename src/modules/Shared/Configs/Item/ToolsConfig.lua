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
    self.Tools = {
        ["Watering Can"] = {
            Name = "Watering Can",
            Icon = "rbxassetid://",
            Rarity = "Common",
            Cooldown = 10
        },
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Tools: { [string]:  {
        Name: string,
        Icon: string,
        Rarity: ItemTypes.Rarity,
        Cooldown: number,
        MaxDurability: number?,
    }},
}

export type Module = typeof(ToolsConfig) & ModuleData

(ToolsConfig :: any):_Init()

return ToolsConfig :: Module