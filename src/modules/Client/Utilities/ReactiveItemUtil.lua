--[=[
    @class ReactiveItemUtil
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ReactiveItemUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ReactiveItemUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ReactiveItemUtil.ToReactive(self: Module, item: ItemTypes.Item): ReactiveItemTypes.ReactiveItem
    if item.Category == "Plant" then
        return {
            Id = item.Id,
            Name = item.Name,
            Category = item.Category,
            GeneticNumber = item.GeneticNumber,
            GrowthTime = ValueObject.new(item.GrowthTime),
            Xp = ValueObject.new(item.Xp),
            LastProduction = ValueObject.new(item.LastProduction),
            Mutations = ValueObject.new(item.Mutations),
            LevelTreeChoices = ValueObject.new(item.LevelTreeChoices),
        }
    elseif item.Category == "Material" then
        return {
            Id = item.Id,
            Name = item.Name,
            Category = item.Category,
            Amount = ValueObject.new(item.Amount),
        }
    elseif item.Category == "Pack" then
        return {
            Id = item.Id,
            Name = item.Name,
            Category = item.Category,
            Amount = ValueObject.new(item.Amount),
        }
    elseif item.Category == "Currency" then
        return {
            Id = item.Id,
            Name = item.Name,
            Category = item.Category,
            Amount = ValueObject.new(item.Amount),
        }
    end

    error("Unknown item category: " .. tostring((item :: any).Category))
end

function ReactiveItemUtil.ToPlain(self: Module, reactiveItem: ReactiveItemTypes.ReactiveItem): ItemTypes.Item
    if reactiveItem.Category == "Plant" then
        return {
            Id = reactiveItem.Id,
            Name = reactiveItem.Name,
            Category = reactiveItem.Category,
            GeneticNumber = reactiveItem.GeneticNumber,
            GrowthTime = reactiveItem.GrowthTime.Value,
            Xp = reactiveItem.Xp.Value,
            LastProduction = reactiveItem.LastProduction.Value,
            Mutations = reactiveItem.Mutations.Value,
            LevelTreeChoices = reactiveItem.LevelTreeChoices.Value,
        }
    elseif reactiveItem.Category == "Material" then
        return {
            Id = reactiveItem.Id,
            Name = reactiveItem.Name,
            Category = reactiveItem.Category,
            Amount = reactiveItem.Amount.Value,
        }
    elseif reactiveItem.Category == "Pack" then
        return {
            Id = reactiveItem.Id,
            Name = reactiveItem.Name,
            Category = reactiveItem.Category,
            Amount = reactiveItem.Amount.Value,
        }
    elseif reactiveItem.Category == "Currency" then
        return {
            Id = reactiveItem.Id,
            Name = reactiveItem.Name,
            Category = reactiveItem.Category,
            Amount = reactiveItem.Amount.Value,
        }
    end

    error("Unknown item category: " .. tostring((reactiveItem :: any).Category))
end

function ReactiveItemUtil.SyncFromPlain(self: Module, reactiveItem: ReactiveItemTypes.ReactiveItem, item: ItemTypes.Item)
    if reactiveItem.Category == "Plant" and item.Category == "Plant" then
        reactiveItem.GrowthTime.Value = item.GrowthTime
        reactiveItem.Xp.Value = item.Xp
        reactiveItem.LastProduction.Value = item.LastProduction
        reactiveItem.Mutations.Value = item.Mutations
        reactiveItem.LevelTreeChoices.Value = item.LevelTreeChoices
    elseif reactiveItem.Category == "Material" and item.Category == "Material" then
        reactiveItem.Amount.Value = item.Amount
    elseif reactiveItem.Category == "Pack" and item.Category == "Pack" then
        reactiveItem.Amount.Value = item.Amount
    elseif reactiveItem.Category == "Currency" and item.Category == "Currency" then
        reactiveItem.Amount.Value = item.Amount
    end
end

function ReactiveItemUtil.OnItemCategory(
    self: Module,
    item: ReactiveItemTypes.ReactiveItem,
    cbs: {
        Plant: ((item: ReactiveItemTypes.ReactivePlantItem) -> ())?,
        Material: ((item: ReactiveItemTypes.ReactiveMaterialItem) -> ())?,
        Pack: ((item: ReactiveItemTypes.ReactivePackItem) -> ())?,
        Currency: ((item: ReactiveItemTypes.ReactiveCurrencyItem) -> ())?,
        All: ((item: ReactiveItemTypes.ReactiveItem) -> ())?,
        Other: ((item: ReactiveItemTypes.ReactiveItem) -> ())?,
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
    elseif item.Category == "Pack" then
        if cbs.Pack then
            cbs.Pack(item)
            return
        end
    elseif item.Category == "Currency" then
        if cbs.Currency then
            cbs.Currency(item)
            return
        end
    end

    if cbs.Other then
        cbs.Other(item)
    end
end

return ReactiveItemUtil :: Module
