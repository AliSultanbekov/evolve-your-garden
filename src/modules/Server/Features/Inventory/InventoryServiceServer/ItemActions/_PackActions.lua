--[=[
    @class Pack
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent:FindFirstAncestor("Inventory").loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PackUtil = require("PackUtil")
local InventoryTypesServer = require("InventoryTypesServer")
local ItemUtil = require("ItemUtil")
local GeneralTypesShared = require("GeneralTypesShared")
local GeneralEnums = require("GeneralEnums")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Pack = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(Pack) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function Pack.Open(context: InventoryTypesServer.ItemActionContext): GeneralTypesShared.DefaultResult
    local Item = context.Item :: ItemTypes.PackItem
    local Amount = context.Params.Amount or 1

    if typeof(Amount) ~= "number" or Amount < 1 or math.floor(Amount) ~= Amount then
        return GeneralEnums.Result.Fail
    end

    if Item.Amount < Amount then
        return GeneralEnums.Result.Fail
    end

    local Contents: { ItemTypes.Item } = {}

    for _, rawItem in PackUtil:Open(Item.Name, Amount) do
        table.insert(Contents, ItemUtil:ProcessRawItem(rawItem))
    end

    if not context.Gateway.CanFitItems(Contents) then
        return GeneralEnums.Result.Fail
    end

    context.Gateway.RemoveItems({
        {
            Id = Item.Id,
            Name = Item.Name,
            Category = "Pack" :: "Pack",
            Amount = Amount,
        },
    })

    context.Gateway.AddItems(Contents, true)

    return GeneralEnums.Result.Success
end

return Pack :: Module