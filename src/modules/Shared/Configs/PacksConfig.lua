--[=[
    @class PacksConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PacksConfig = {}

-- [ Private Functions ] --
function PacksConfig._Init(self: Module)
    self.Packs = {
        ["Super Pack"] = {
            Name = "Starter Pack",
            Rarity = "Common",
            PlantPool = {
                ["Snow Blossom"] = 100,
            }
        },
        ["Mega Pack"] = {
            Name = "Starter Pack",
            Rarity = "Celestial",
            PlantPool = {
                ["Snow Blossom"] = 100,
            }
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type PackEntry = {
    Name: string,
    Rarity: string,
    PlantPool: {
        [string]: number
    }
}

type ModuleData = {
    Packs: { [string]: PackEntry },
}

export type Module = typeof(PacksConfig) & ModuleData

(PacksConfig :: any):_Init()

return PacksConfig :: Module