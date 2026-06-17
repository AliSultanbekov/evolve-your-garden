--[=[
    @class PackUtil
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ChanceClass = require("ChanceClass")
local PacksConfig = require("PacksConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(PackUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PackUtil.Open(self: Module, packName: string, amount: number): { ItemTypes.RawPlantItem }
    local PackConfig = PacksConfig.Packs[packName]
    local ChanceObject = ChanceClass.new(PackConfig.PlantPool)

    local Plants: { ItemTypes.RawPlantItem }  = table.create(amount)
    
    for i = 1, amount do
        local PlantName = ChanceObject:Choose()
        table.insert(Plants, {
            Name = PlantName,
            Category = "Plant",
        })
    end

    return Plants
end

return PackUtil :: Module