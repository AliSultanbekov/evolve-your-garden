--[=[
    @class ToolbarServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _DataServiceServer: typeof(require("DataServiceServer")),
    _PlayersEquippedToolIds: {
        [string]: ItemTypes.ItemId
    }
}

export type Module = typeof(ToolbarServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolbarServiceServer.EquipItem(self: Module, player: Player, itemId: ItemTypes.ItemId)
    local Item = self._InventoryServiceServer:GetItem(player, itemId)

    if not Item then
        return
    end

    if Item.Category ~= "Tool" then
        return
    end

    
end

function ToolbarServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._PlayersEquippedToolIds = {}
end

function ToolbarServiceServer.Start(self: Module)
    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(Data)
            return
        end))
    end)
end

return ToolbarServiceServer :: Module