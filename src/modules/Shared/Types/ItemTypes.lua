--[=[
    @class ItemTypes
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --
export type ItemId = string
export type Category = "Plant" | "Material" | "Pack" | "Currency"
export type StorageMode = "Unique" | "Stackable"

-- ===== Building blocks =====
-- Common to every item, regardless of category or storage mode.
export type Common = {
    Id: ItemId,
    Name: string,
}

-- Added to any item whose StorageMode is "Stackable".
export type Stackable = {
    Amount: number,
}

export type LevelTreeChoices = {
    [number]: number
}

-- ===== Category-specific data =====

export type PlantData = {
    GrowthTime: number,
    Xp: number,
    LastProduction: number,
    GeneticNumber: number,
    Mutations: { string },
    LevelTreeChoices: LevelTreeChoices,
}

export type MaterialData = {}

-- ===== Concrete items =====
-- Composed: Common + (Stackable if applicable) + category data + Category tag.
-- The presence/absence of Stackable encodes the StorageMode in the type itself.
export type PlantItem = Common & PlantData & {
    Category: "Plant",
}
export type MaterialItem = Common & Stackable & MaterialData & {
    Category: "Material",
}
export type PackItem = Common & Stackable & {
    Category: "Pack",
}
export type CurrencyItem = Common & Stackable & {
    Category: "Currency"
}

export type Item = PlantItem | MaterialItem | PackItem | CurrencyItem

-- ===== Storage-mode groupings =====
-- Unions of concrete items that share a storage mode.
-- These ARE Items (not structural views), so they round-trip into Inventory: { [ID]: Item }.
-- Keep in sync with ItemConfig.CategoryToStorageMode whenever you add a category.
export type UniqueItem = PlantItem
export type StackableItem = MaterialItem
export type StorageItem = Item

-- ===== Raw items (input to ProcessRawItem) =====
-- ID + computed defaults are optional; processing fills them in.
export type RawPlantItem = {
    Id: ItemId?,
    Name: string,
    Category: "Plant",
    GrowthTime: number?,
    Xp: number?,
    LastProduction: number?,
    GeneticNumber: number?,
    Mutations: { string }?,
    LevelTreeChoices: LevelTreeChoices?,
}
export type RawMaterialItem = {
    Id: ItemId?,
    Name: string,
    Category: "Material",
    Amount: number?,
}
export type RawPackItem = {
    Id: ItemId?,
    Name: string,
    Category: "Pack",
    Amount: number?,
}
export type RawCurrencyItem = {
    Id: ItemId?,
    Name: string,
    Category: "Currency",
    Amount: number?,
}

export type RawItem = RawPlantItem | RawMaterialItem | RawPackItem | RawCurrencyItem

return nil
