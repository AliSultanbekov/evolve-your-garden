--[=[
    @class ItemConfig
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PlantsConfig = require("PlantsConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemConfig = {
    CategoryToStorageMode = {
        ["Plant"] = "Unique",
        ["Material"] = "Stackable",
        ["Currency"] = "Stackable",
    }
}

-- [ Types ] --
type ModuleData = {
    CategoryToStorageMode: {
        [ItemTypes.Category]: "Unqiue" | "Stackable"
    }
}

export type Module = typeof(ItemConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemConfig.GetCategory(self: Module, itemName: string): ItemTypes.Category
    if PlantsConfig[itemName] then
        return "Plant"
    end
    -- TODO: check MaterialsConfig / CurrenciesConfig once those registries exist.
    -- For now, anything not a known Plant is treated as a Material — drop pools
    -- currently only contain materials, so this is safe in practice.
    return "Material"
end

return ItemConfig :: Module
