--[=[
    @class ToolsServiceServer

    Server half of the tools orchestrator: validates activations, owns the
    per-item tool state registry, and runs server behaviors on equip /
    activate / unequip. Mirrors the client orchestrator - the client predicts
    feel, this side owns truth.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")
local ToolsConfig = require("ToolsConfig")
local RxPlayerUtils = require("RxPlayerUtils")
local PlayerToUserId = require("PlayerToUserId")
local Brio = require("Brio")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceServer: typeof(require("ToolbarServiceServer")),
    _ToolsNetworkServer: typeof(require("ToolsNetworkServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _Maid: Maid.Maid,
    _UserIdToItemIdToToolState: {
        [string]: {
            [ItemTypes.ItemId]: ToolsTypesShared.ToolState
        }
    },
    _UserIdToEquipMaid: {
        [string]: Maid.Maid
    },
    _UserIdToEquippedToolItem: {
        [string]: ItemTypes.Item?
    },
    _UserIdToLastActivated: {
        [string]: number
    },
    _ToolBehaviors: {
        [string]: typeof(require(script.Parent.Behaviors._TestBehavior))
    }
}

export type Module = typeof(ToolsServiceServer) & ModuleData

-- [ Private Functions ] --
function ToolsServiceServer._GetToolState(self: Module, userId: string, itemId: ItemTypes.ItemId): ToolsTypesShared.ToolState
    local ItemIdToToolState = self._UserIdToItemIdToToolState[userId]

    if not ItemIdToToolState[itemId] then
        ItemIdToToolState[itemId] = {}
    end

    return ItemIdToToolState[itemId]
end

-- [ Public Functions ] --
function ToolsServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarServiceServer = self._ServiceBag:GetService(require("ToolbarServiceServer"))
    self._ToolsNetworkServer = self._ServiceBag:GetService(require("ToolsNetworkServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._Maid = Maid.new()
    self._UserIdToItemIdToToolState = {}
    self._UserIdToEquipMaid = {}
    self._UserIdToEquippedToolItem = {}
    self._UserIdToLastActivated = {}
    self._ToolBehaviors = {
        ["Test"] = require(script.Parent.Behaviors._TestBehavior),
        ["Watering Can"] = require(script.Parent.Behaviors._WateringCanBehavior),
    }
end

function ToolsServiceServer.Start(self: Module)
    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local PlayerMaid, Player = brio:ToMaidAndValue()
        local UserId = PlayerToUserId(Player)

        self._UserIdToItemIdToToolState[UserId] = {}
        self._UserIdToEquipMaid[UserId] = Maid.new()
        self._UserIdToLastActivated[UserId] = 0

        PlayerMaid:Add(function()
            self._UserIdToEquipMaid[UserId]:Destroy()
            self._UserIdToEquipMaid[UserId] = nil
            self._UserIdToItemIdToToolState[UserId] = nil
            self._UserIdToEquippedToolItem[UserId] = nil
            self._UserIdToLastActivated[UserId] = nil
        end)
    end)

    self._ToolbarServiceServer.Signals.ItemEquipped:Connect(function(player: Player, itemId: ItemTypes.ItemId)
        local UserId = PlayerToUserId(player)
        local EquipMaid = self._UserIdToEquipMaid[UserId]

        if not EquipMaid then
            return
        end

        EquipMaid:DoCleaning()

        local Item = self._InventoryServiceServer:GetItem(player, itemId)

        if not Item then
            return
        end

        self._UserIdToEquippedToolItem[UserId] = Item

        local Behavior = self._ToolBehaviors[Item.Name]

        if not Behavior then
            return
        end

        Behavior:OnEquipped(player, EquipMaid, {
            ServiceBag = self._ServiceBag,
            Item = Item,
            State = self:_GetToolState(UserId, Item.Id)
        })
    end)

    self._ToolbarServiceServer.Signals.ItemUnequipped:Connect(function(player: Player, itemId: ItemTypes.ItemId)
        local UserId = PlayerToUserId(player)
        local EquipMaid = self._UserIdToEquipMaid[UserId]
        local Item = self._UserIdToEquippedToolItem[UserId]

        self._UserIdToEquippedToolItem[UserId] = nil

        if Item then
            local Behavior = self._ToolBehaviors[Item.Name]

            if Behavior then
                Behavior:OnUnequipped(player, {
                    ServiceBag = self._ServiceBag,
                    Item = Item,
                    State = self:_GetToolState(UserId, Item.Id)
                })
            end
        end

        if EquipMaid then
            EquipMaid:DoCleaning()
        end
    end)

    self._ToolsNetworkServer.RemoteEvents.ActivateTool:Connect(function(player: Player, packet: ToolsTypesShared.ActivateToolRemotePacket)
        local UserId = PlayerToUserId(player)
        local Item = self._UserIdToEquippedToolItem[UserId]
    
        if not Item then
            return
        end
    
        local Behavior = self._ToolBehaviors[Item.Name]
    
        if not Behavior then
            return
        end
    
        local ToolConfig = ToolsConfig.Tools[Item.Name]
    
        if ToolConfig then
            local LastActivated = self._UserIdToLastActivated[UserId] or 0
    
            if os.clock() - LastActivated < ToolConfig.Cooldown then
                return
            end
        end
    
        self._UserIdToLastActivated[UserId] = os.clock()
    
        Behavior:OnActivated(player, {
            ServiceBag = self._ServiceBag,
            Item = Item,
            State = self:_GetToolState(UserId, Item.Id),
            Params = packet.Params or {},
        })
    end)

    self._Maid:Add(self._InventoryServiceServer.Signals.ItemRemoved:Connect(function(player: Player, itemId: ItemTypes.ItemId)
        local UserId = PlayerToUserId(player)
        local ItemIdToToolState = self._UserIdToItemIdToToolState[UserId]

        if ItemIdToToolState then
            ItemIdToToolState[itemId] = nil
        end
    end))
end

return ToolsServiceServer :: Module
