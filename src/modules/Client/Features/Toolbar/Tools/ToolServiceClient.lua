--[=[
    @class ToolServiceClient

    Client half of the tools orchestrator: owns behaviors, the per-item tool
    state registry, the activation cooldown and the tools wire. Mirrors
    ToolsServiceServer - the client behavior builds activation params, the
    server behavior validates them.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local Maid = require("Maid")
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")
local ToolsConfig = require("ToolsConfig")

local TestBehavior = require(script.Parent.Behaviors._TestBehavior)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolServiceClient = {}

-- [ Types ] --
export type Signals = {
    ToolActivated: Signal.Signal<ItemTypes.ItemId>
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _ToolsNetworkClient: typeof(require("ToolsNetworkClient")),
    _Maid: Maid.Maid,
    _EquipMaid: Maid.Maid,
    _ItemIdToToolState: {
        [ItemTypes.ItemId]: ToolsTypesShared.ToolState
    },
    _ToolBehaviors: {
        [string]: TestBehavior.Module
    },
    _EquippedToolItem: ReactiveItemTypes.ReactiveItem?,
    _LastActivated: number,
    Signals: Signals,
}

export type Module = typeof(ToolServiceClient) & ModuleData

-- [ Private Functions ] --
function ToolServiceClient._GetToolState(self: Module, itemId: ItemTypes.ItemId): ToolsTypesShared.ToolState
    if not self._ItemIdToToolState[itemId] then
        self._ItemIdToToolState[itemId] = {}
    end

    return self._ItemIdToToolState[itemId]
end

-- [ Public Functions ] --
function ToolServiceClient.ActivateTool(self: Module)
    local Item = self._EquippedToolItem

    if not Item then
        return
    end

    local Behavior = self._ToolBehaviors[Item.Name]

    if not Behavior then
        return
    end

    local ToolConfig = ToolsConfig.Tools[Item.Name]

    if ToolConfig and self._LastActivated + ToolConfig.Cooldown >= os.clock() then
        return
    end

    self._LastActivated = os.clock()

    local ServerParams = {}

    Behavior:OnActivated({
        ServiceBag = self._ServiceBag,
        State = self:_GetToolState(Item.Id),
        Item = Item,
        ServerParams = ServerParams,
    })

    self._ToolsNetworkClient:ActivateTool({ Params = ServerParams })
    self.Signals.ToolActivated:Fire(Item.Id)
end

function ToolServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarServiceClient = self._ServiceBag:GetService(require("ToolbarServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._ToolsNetworkClient = self._ServiceBag:GetService(require("ToolsNetworkClient"))
    self._Maid = Maid.new()
    self._EquipMaid = self._Maid:Add(Maid.new())
    self._ItemIdToToolState = {}
    self._ToolBehaviors = {
        ["Test"] = TestBehavior,
        ["Watering Can"] = require(script.Parent.Behaviors._WateringCanBehavior),
    }
    self._EquippedToolItem = nil
    self._LastActivated = 0
    self.Signals = {
        ToolActivated = Signal.new()
    } :: any
end

function ToolServiceClient.Start(self: Module)
    self._Maid:Add(self._ToolbarServiceClient.Signals.ItemEquipped:Connect(function(itemId: ItemTypes.ItemId)
        self._EquipMaid:DoCleaning()

        local Item = self._InventoryServiceClient:GetItem(itemId)

        if not Item then
            return
        end

        self._EquippedToolItem = Item

        local Behavior = self._ToolBehaviors[Item.Name]

        if not Behavior then
            return
        end

        Behavior:OnEquipped(self._EquipMaid, {
            ServiceBag = self._ServiceBag,
            State = self:_GetToolState(Item.Id),
            Item = Item,
        })
    end))

    self._Maid:Add(self._ToolbarServiceClient.Signals.ItemUnequipped:Connect(function()
        local Item = self._EquippedToolItem

        self._EquippedToolItem = nil
        self._LastActivated = 0

        if Item then
            local Behavior = self._ToolBehaviors[Item.Name]

            if Behavior then
                Behavior:OnUnequipped({
                    ServiceBag = self._ServiceBag,
                    State = self:_GetToolState(Item.Id),
                    Item = Item,
                })
            end
        end

        self._EquipMaid:DoCleaning()
    end))

    self._Maid:Add(self._InventoryServiceClient.Signals.ItemRemoved:Connect(function(itemId: ItemTypes.ItemId)
        self._ItemIdToToolState[itemId] = nil
    end))
end

return ToolServiceClient :: Module
