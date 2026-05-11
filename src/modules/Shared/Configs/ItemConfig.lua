--[=[
    @class ItemConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PlantsConfig = require("PlantsConfig")
local MaterialsConfig = require("MaterialsConfig")

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
    elseif MaterialsConfig[itemName] then
        return "Material"
    else
        error("Issue")
    end
end

function ItemConfig.GetIcon(self: Module, itemName: string, itemCategory: ItemTypes.Category?): string
    local Category = itemCategory or self:GetCategory(itemName)

    if Category == "Plant" then
        return PlantsConfig.Plants[itemName].Icon
    elseif Category == "Material" then
        return ""
    end

    error("Issue")
end

return ItemConfig :: Module
