--[=[
    @class GardenTypesClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local GardenTypesShared = require("GardenTypesShared")
local ValueObject = require("ValueObject")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemTypes = require("ItemTypes")
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ReactiveGarden = {
    GardenId: GardenTypesShared.GardenId,
    Owner: ValueObject.ValueObject<string?>,
    Level: ValueObject.ValueObject<number?>,
    Slots: ReactiveSlots,
}
export type ReactiveGardens = {
    [GardenTypesShared.GardenId]: ReactiveGarden
}
export type ReactiveSlot = {
    Id: GardenTypesShared.SlotId,
    Plant: ValueObject.ValueObject<ReactiveItemTypes.ReactivePlantItem?>,
    Harvest: ObservableMap.ObservableMap<ItemTypes.ItemId, ReactiveItemTypes.ReactiveItem>,
}
export type ReactiveSlots = ObservableMap.ObservableMap<GardenTypesShared.SlotId, ReactiveSlot>
export type ReactiveHarvest = ObservableMap.ObservableMap<GardenTypesShared.SlotId, ReactiveItemTypes.ReactiveItem>
export type SlotModel = typeof(ReplicatedStorage.Assets.Objects.Garden.Slot)
export type GardenModel = typeof(ReplicatedStorage.Assets.Objects.Garden.Upgrades["1"])

return nil
