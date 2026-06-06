--[=[
    @class PackStoreUtil

    Converts plain network packs (PackStoreTypesShared) into client-side
    reactive packs (PackStoreTypesClient) and back. Immutable fields stay
    plain; the mutable Left count is wrapped in a ValueObject so stock
    changes update the UI without rebuilding the pack card.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local PackStoreTypesShared = require("PackStoreTypesShared")
local PackStoreTypesClient = require("PackStoreTypesClient")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(PackStoreUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PackStoreUtil.ToReactive(self: Module, pack: PackStoreTypesShared.Pack): PackStoreTypesClient.ReactivePack
    return {
        Id = pack.Id,
        Category = pack.Category,
        Name = pack.Name,
        Stock = pack.Stock,
        Left = ValueObject.new(pack.Left),
    }
end

function PackStoreUtil.ToPlain(self: Module, reactivePack: PackStoreTypesClient.ReactivePack): PackStoreTypesShared.Pack
    return {
        Id = reactivePack.Id,
        Category = reactivePack.Category,
        Name = reactivePack.Name,
        Stock = reactivePack.Stock,
        Left = reactivePack.Left.Value,
    }
end

function PackStoreUtil.SyncFromPlain(self: Module, reactivePack: PackStoreTypesClient.ReactivePack, pack: PackStoreTypesShared.Pack)
    reactivePack.Left.Value = pack.Left
end

return PackStoreUtil :: Module
