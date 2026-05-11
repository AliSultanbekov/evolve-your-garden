--[=[
    @class ReactiveItemUtil
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemUtil = require("ItemUtil")
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
    local ReactiveItem: ReactiveItemTypes.ReactiveItem

    ItemUtil:OnItemCategory(item, {
        ["Plant"] = function(item: ItemTypes.PlantItem)
            ReactiveItem = {
                Id = item.Id,
                Name = item.Name,
                Category = item.Category,
                GeneticNumber = item.GeneticNumber,
                GrowthTime = ValueObject.new(item.GrowthTime),
                LastProduction = ValueObject.new(item.LastProduction),
                Mutations = ValueObject.new(item.Mutations),
            }
        end,
        ["Material"] = function(item: ItemTypes.MaterialItem)
            ReactiveItem = {
                Id = item.Id,
                Name = item.Name,
                Category = item.Category,
                Amount = ValueObject.new(item.Amount),
            }
        end,
    })

    return ReactiveItem
end

function ReactiveItemUtil.ToPlain(self: Module, reactiveItem: ReactiveItemTypes.ReactiveItem): ItemTypes.Item
    local PlainItem: ItemTypes.Item

    self:OnItemCategory(reactiveItem, {
        ["Plant"] = function(item: ReactiveItemTypes.ReactivePlantItem)
            PlainItem = {
                Id = item.Id,
                Name = item.Name,
                Category = item.Category,
                GeneticNumber = item.GeneticNumber,
                GrowthTime = item.GrowthTime.Value,
                LastProduction = item.LastProduction.Value,
                Mutations = item.Mutations.Value,
            }
        end,
        ["Material"] = function(item: ReactiveItemTypes.ReactiveMaterialItem)
            PlainItem = {
                Id = item.Id,
                Name = item.Name,
                Category = item.Category,
                Amount = item.Amount.Value,
            }
        end,
    })

    return PlainItem
end

function ReactiveItemUtil.SyncFromPlain(self: Module, reactiveItem: ReactiveItemTypes.ReactiveItem, item: ItemTypes.Item)
    if reactiveItem.Category == "Plant" and item.Category == "Plant" then
        reactiveItem.GrowthTime.Value = item.GrowthTime
        reactiveItem.LastProduction.Value = item.LastProduction
        reactiveItem.Mutations.Value = item.Mutations
    elseif reactiveItem.Category == "Material" and item.Category == "Material" then
        reactiveItem.Amount.Value = item.Amount
    end
end

function ReactiveItemUtil.OnItemCategory(
    self: Module,
    item: ReactiveItemTypes.ReactiveItem,
    cbs: {
        Plant: ((item: ReactiveItemTypes.ReactivePlantItem) -> ())?,
        Material: ((item: ReactiveItemTypes.ReactiveMaterialItem) -> ())?,
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
    end

    if cbs.Other then
        cbs.Other(item)
    end
end

return ReactiveItemUtil :: Module
