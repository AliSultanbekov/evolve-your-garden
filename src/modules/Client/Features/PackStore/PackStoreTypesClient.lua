--[=[
    @class PackStoreTypesClient

    Client-side mirror of PackStoreTypesShared.Pack with per-attribute
    observables for fine-grained reactivity. Immutable fields stay as plain
    values; the mutable Left count is wrapped in ValueObject so stock changes
    update the UI without rebuilding the pack card.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ObservableMap = require("ObservableMap")
local PackStoreTypesShared = require("PackStoreTypesShared")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ReactivePack = {
    -- Immutable
    Id: PackStoreTypesShared.PackId,
    Category: PackStoreTypesShared.Category,
    Name: string,
    Stock: number,

    -- Reactive
    Left: ValueObject.ValueObject<number>,
}

-- Stable map reference (per-id Pack isn't replaced; its inner Left ValueObject
-- mutates). ComputedPairs over this never remounts cards.
export type Packs = ObservableMap.ObservableMap<PackStoreTypesShared.PackId, ReactivePack>

return nil
