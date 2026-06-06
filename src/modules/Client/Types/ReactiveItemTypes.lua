--[=[
    @class ReactiveItemTypes

    Client-side mirror of ItemTypes with per-attribute observables for
    fine-grained reactivity. Immutable fields stay as plain values;
    mutable fields are wrapped in ValueObject so individual attribute
    changes don't force whole-item re-renders.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --

-- ===== Building blocks =====
-- Common to every reactive item — same as ItemTypes.Common but client-side.
type ReactiveCommon = {
    Id: ItemTypes.ItemId,
    Name: string,
}

-- Added to any reactive item whose StorageMode is "Stackable" (mirror of ItemTypes.Stackable).
type ReactiveStackable = {
    Amount: ValueObject.ValueObject<number>,
}

-- ===== Category-specific reactive data =====

type ReactivePlantData = {
    GeneticNumber: number,

    GrowthTime: ValueObject.ValueObject<number>,
    Xp: ValueObject.ValueObject<number>,
    LastProduction: ValueObject.ValueObject<number>,
    Mutations: ValueObject.ValueObject<{ string }>,
    LevelTreeChoices: ValueObject.ValueObject<ItemTypes.LevelTreeChoices>,
}

type ReactiveMaterialData = {}

-- ===== Concrete reactive items =====
export type ReactivePlantItem = ReactiveCommon & ReactivePlantData & {
    Category: "Plant",
}

export type ReactiveMaterialItem = ReactiveCommon & ReactiveStackable & ReactiveMaterialData & {
    Category: "Material",
}

export type ReactivePackItem = ReactiveCommon & ReactiveStackable & {
    Category: "Pack",
}

export type ReactiveCurrencyItem = ReactiveCommon & ReactiveStackable & {
    Category: "Currency",
}

export type ReactiveItem = ReactivePlantItem | ReactiveMaterialItem | ReactivePackItem | ReactiveCurrencyItem

-- ===== Storage-mode groupings (parallel to ItemTypes.UniqueItem / StackableItem) =====
export type ReactiveUniqueItem = ReactivePlantItem
export type ReactiveStackableItem = ReactiveMaterialItem | ReactivePackItem | ReactiveCurrencyItem
export type ReactiveStorageItem = ReactiveItem

-- ===== The inventory shape on the client =====
-- Stable map references (per-id ReactiveItem doesn't get replaced; its inner
-- ValueObjects mutate). ComputedPairs over this never remounts cards.
export type ReactiveInventory = ObservableMap.ObservableMap<ItemTypes.ItemId, ReactiveItem>

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
