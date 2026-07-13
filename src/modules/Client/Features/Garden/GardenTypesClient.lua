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
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ReactiveGarden = {
    Id: GardenTypesShared.GardenId,
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
    Harvest: ReactiveItemTypes.ReactiveItems,
}
export type ReactiveSlots = ObservableMap.ObservableMap<GardenTypesShared.SlotId, ReactiveSlot>
export type SlotModel = typeof(ReplicatedStorage.Assets.Objects.Garden.Slot)
export type GardenModel = typeof(ReplicatedStorage.Assets.Objects.Garden.Upgrades["1"])
export type GardenFolder = typeof(workspace.World.Gardens["1"])
export type SlotInfo = {
    GardenId: GardenTypesShared.GardenId,
    SlotId: GardenTypesShared.SlotId,
}

return nil
