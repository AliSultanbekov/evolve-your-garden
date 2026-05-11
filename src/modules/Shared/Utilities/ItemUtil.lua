
--[=[
    @class ItemUtil
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemConfig = require("ItemConfig")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ItemUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

function ItemUtil.ProcessRawItem(self: Module, rawItem: ItemTypes.RawItem): ItemTypes.Item
    local id: ItemTypes.ItemId

    if self:CategoryToStorageMode(rawItem.Category) == "Unique" then
        id = HttpService:GenerateGUID(false)
    else
        id = rawItem.Name
    end
    
    if rawItem.Category == "Plant" then
        return {
            Id = id,
            Name = rawItem.Name,
            Category = rawItem.Category,
            GrowthTime = rawItem.GrowthTime or 0,
            LastProduction = rawItem.LastProduction or 0,
            GeneticNumber = rawItem.GeneticNumber or math.random(1, (2^31)-1),
            Mutations = rawItem.Mutations or {},
        }
    elseif rawItem.Category == "Material" then
        return {
            Id = id,
            Name = rawItem.Name,
            Category = rawItem.Category,
            Amount = rawItem.Amount or 1,
        }
    end

    error("Unknown item category: " .. tostring(rawItem.Category))
end

function ItemUtil.OnItemCategory(
    self: Module,
    item: ItemTypes.Item,
    cbs: {
        Plant: ((item: ItemTypes.PlantItem) -> ())?,
        Material: ((item: ItemTypes.MaterialItem) -> ())?,
        All: ((item: ItemTypes.Item) -> ())?,
        Other: ((item: ItemTypes.Item) -> ())?,
    }
)
    if cbs.All then
        cbs.All(item)
    end

    if item.Category == "Plant" then
        if cbs.Plant then
            cbs.Plant(item)
            return
        end
    elseif item.Category == "Material" then
        if cbs.Material then
            cbs.Material(item)
            return
        end
    end

    if cbs.Other then
        cbs.Other(item)
    end
end

function ItemUtil.OnStorageMode(
    self: Module,
    item: ItemTypes.StorageItem,
    cbs: {
        Unique: ((item: ItemTypes.UniqueItem) -> ())?,
        Stackable: ((item: ItemTypes.StackableItem) -> ())?,
        All: ((item: ItemTypes.StorageItem) -> ())?,
        Other: ((item: ItemTypes.StorageItem) -> ())?,
    }
)
    if cbs.All then
        cbs.All(item)
    end

    local mode = self:CategoryToStorageMode(item.Category)
    if mode == "Unique" and cbs.Unique then
        cbs.Unique(item :: ItemTypes.UniqueItem)
        return
    elseif mode == "Stackable" and cbs.Stackable then
        cbs.Stackable(item :: ItemTypes.StackableItem)
        return
    end

    if cbs.Other then
        cbs.Other(item)
    end
end

function ItemUtil.CategoryToStorageMode(self: Module, category: ItemTypes.Category): ItemTypes.StorageMode
    return ItemConfig.CategoryToStorageMode[category]
end

export type MakeRawOptions = {
    Amount: number?,
    GeneticNumber: number?,
    GrowthTime: number?,
    LastProduction: number?,
    Mutations: { string }?,
}

function ItemUtil.MakeRawFromName(self: Module, name: string, opts: MakeRawOptions?): ItemTypes.RawItem
    local o = opts or {} :: MakeRawOptions
    local category = ItemConfig:GetCategory(name)

    if category == "Material" then
        return {
            Name = name,
            Category = "Material",
            Amount = o.Amount or 1,
        }
    elseif category == "Plant" then
        return {
            Name = name,
            Category = "Plant",
            GeneticNumber = o.GeneticNumber,
            GrowthTime = o.GrowthTime,
            LastProduction = o.LastProduction,
            Mutations = o.Mutations,
        }
    end

    error("Unknown category for item: " .. name)
end

return ItemUtil :: Module
