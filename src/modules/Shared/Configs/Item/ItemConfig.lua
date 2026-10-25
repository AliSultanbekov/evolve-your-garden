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
local CurrenciesConfig = require("CurrenciesConfig")
local PacksConfig = require("PacksConfig")
local ToolsConfig = require("ToolsConfig")
local Table = require("Table")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemConfig = {}

-- [ Private Functions ] --
function ItemConfig._Init(self: Module)
    self.CategoryToStorageMode = {
        ["Plant"] = "Unique",
        ["Material"] = "Stackable",
        ["Pack"] = "Stackable",
        ["Currency"] = "Stackable",
        ["Tool"] = "Unique",
    }
    self.RarityLayoutOrder = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5,
        ["Mythic"] = 6,
        ["Celestial"] = 7,
    }
    self.Categories = {"Plant", "Material", "Pack", "Currency", "Tool"}
    self.MaxAmount = 100000
end

-- [ Public Functions ] --
function ItemConfig.GetCategory(self: Module, itemName: string): ItemTypes.Category
    if PlantsConfig.Plants[itemName] then
        return "Plant"
    elseif MaterialsConfig.Materials[itemName] then
        return "Material"
    elseif PacksConfig.Packs[itemName] then
        return "Pack"
    elseif CurrenciesConfig.Currencies[itemName] then
        return "Currency"
    elseif ToolsConfig.Tools[itemName] then
        return "Tool"
    else
        error("No category found for item: " .. tostring(itemName))
    end
end

function ItemConfig.GetIcon(self: Module, itemName: string, itemCategory: ItemTypes.Category?): string
    local Category = itemCategory or self:GetCategory(itemName)

    if Category == "Plant" then
        return PlantsConfig.Plants[itemName].Icon
    elseif Category == "Material" then
        return MaterialsConfig.Materials[itemName].Icon
    elseif Category == "Pack" then
        return PacksConfig.Packs[itemName].Icon
    elseif Category == "Currency" then
        return CurrenciesConfig.Currencies[itemName].Icon
    elseif Category == "Tool" then
        return ToolsConfig.Tools[itemName].Icon
    end

    error("No icon found for item: " .. tostring(itemName) .. " (" .. tostring(Category) .. ")")
end

function ItemConfig.GetRarity(self: Module, itemName: string, itemCategory: ItemTypes.Category?): ItemTypes.Rarity
    local Category = itemCategory or self:GetCategory(itemName)

    if Category == "Plant" then
        return PlantsConfig.Plants[itemName].Rarity
    elseif Category == "Material" then
        return MaterialsConfig.Materials[itemName].Rarity
    elseif Category == "Pack" then
        return PacksConfig.Packs[itemName].Rarity
    elseif Category == "Currency" then
        return CurrenciesConfig.Currencies[itemName].Rarity
    elseif Category == "Tool" then
        return ToolsConfig.Tools[itemName].Rarity
    end

    error("No rarity found for item: " .. tostring(itemName) .. " (" .. tostring(Category) .. ")")
end

function ItemConfig.GetTags(self: Module, itemName: string, itemCategory: ItemTypes.Category?): { [string]: boolean }
    local Category = itemCategory or self:GetCategory(itemName)

    if Category == "Plant" then
        return PlantsConfig.Plants[itemName].Tags
    elseif Category == "Material" then
        return MaterialsConfig.Materials[itemName].Tags
    elseif Category == "Pack" then
        return PacksConfig.Packs[itemName].Tags
    elseif Category == "Currency" then
        return CurrenciesConfig.Currencies[itemName].Tags
    elseif Category == "Tool" then
        return ToolsConfig.Tools[itemName].Tags
    end

    error("No tags found for item: " .. tostring(itemName) .. " (" .. tostring(Category) .. ")")
end

function ItemConfig.HasTag(self: Module, itemName: string, tag: string, itemCategory: ItemTypes.Category?): boolean
    return self:GetTags(itemName, itemCategory)[tag] == true
end

function ItemConfig.GetAllItemsConfigs(self: Module)
    local ItemsConfigs = {}

    for _, category in pairs(self.Categories) do
        if category == "Plant" then
            ItemsConfigs = Table.merge(ItemsConfigs, PlantsConfig.Plants)
        elseif category == "Material" then
            ItemsConfigs = Table.merge(ItemsConfigs, MaterialsConfig.Materials)
        elseif category == "Pack" then
            ItemsConfigs = Table.merge(ItemsConfigs, PacksConfig.Packs)
        elseif category == "Currency" then
            ItemsConfigs = Table.merge(ItemsConfigs, CurrenciesConfig.Currencies)
        elseif category == "Tool" then
            ItemsConfigs = Table.merge(ItemsConfigs, ToolsConfig.Tools)
        end
    end

    return ItemsConfigs
end

-- [ Types ] --
type ModuleData = {
    CategoryToStorageMode: {
        [ItemTypes.Category]: ItemTypes.StorageMode
    },
    RarityLayoutOrder: { [ItemTypes.Rarity]: number },
    Categories: { ItemTypes.Category },
    MaxAmount: number,
}

export type Module = typeof(ItemConfig) & ModuleData

(ItemConfig :: any):_Init()

return ItemConfig :: Module
