--[=[
    @class Pack
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent:FindFirstAncestor("Inventory").loader).load(script) :: typeof(require)

-- [ Imports ] --
local ProfileConfig = require("ProfileConfig")
local ItemTypes = require("ItemTypes")
local PackUtil = require("PackUtil")
local InventoryTypesServer = require("InventoryTypesServer")
local _ItemUtil = require("ItemUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Pack = {}

-- [ Types ] --
type OpenProps = {
    PlayerData: ProfileConfig.ProfileTemplate,
    Item: ItemTypes.PackItem,
    Amount: number,
    Gateway: InventoryTypesServer.Gateway
}
type ModuleData = {}

export type Module = typeof(Pack) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function Pack.Open(props: OpenProps)
    local Item = props.Item

    if typeof(props.Amount) ~= "number" or props.Amount < 1 or math.floor(props.Amount) ~= props.Amount then
        return
    end
    
    if Item.Amount < props.Amount then
        return
    end
    
    props.Gateway.RemoveItems({
        {
            Id = Item.Id,
            Name = Item.Name,
            Category = "Pack" :: "Pack",
            Amount = props.Amount,
        }
    })

    props.Gateway.AddRawItems(PackUtil:Open(Item.Name, props.Amount))
end

return Pack :: Module