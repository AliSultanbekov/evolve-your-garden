--[=[
    @class ToolsWorldClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Maid = require("Maid")
local RxCharacterUtils = require("RxCharacterUtils")
local Rx = require("Rx")
local AssetProvider = require("AssetProvider")
local ToolsTypesShared = require("ToolsTypesShared")
local ToolsConfig = require("ToolsConfig")

local TestBehavior = require(script.Parent.Behaviors._TestBehavior)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _ToolServiceClient: typeof(require("ToolServiceClient")),
    _Maid: Maid.Maid,
    _ItemIdToToolState: {
        [ItemTypes.ItemId]: ToolsTypesShared.ToolState
    },
    _ToolBehaviors: {
        [string]: TestBehavior.Module
    },
    _EquippedToolItem: ReactiveItemTypes.ReactiveItem?,
    _LastActivated: number,
}

export type Module = typeof(ToolsWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolsWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarServiceClient = self._ServiceBag:GetService(require("ToolbarServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._ToolServiceClient = self._ServiceBag:GetService(require("ToolServiceClient"))

    self._Maid = Maid.new()
    self._ItemIdToToolState = {}
    self._ToolBehaviors = {
        ["Test"] = TestBehavior,
        ["Watering Can"] = require(script.Parent.Behaviors._WateringCanBehavior)
    }
    self._EquippedToolItem = nil
    self._LastActivated = 0
end

function ToolsWorldClient.Start(self: Module)
    local BehaviorMaid = Maid.new()

    self._ToolbarServiceClient.Signals.ItemEquipped:Connect(function(itemId: ItemTypes.ItemId)
        local Item = self._InventoryServiceClient:GetItem(itemId)

        if not Item then
            return
        end

        local Behavior = self._ToolBehaviors[Item.Name]

        if not Behavior then
            return
        end

        self._EquippedToolItem = Item

        if not self._ItemIdToToolState[itemId] then
            self._ItemIdToToolState[itemId] = {}
        end

        Behavior:OnEquipped(BehaviorMaid, {
            State = self._ItemIdToToolState[itemId],
            Item = Item
        })
    end)

    self._ToolbarServiceClient.Signals.ItemUnequipped:Connect(function()
        local Item = self._EquippedToolItem

        if not Item then
            return
        end

        local Behavior = self._ToolBehaviors[Item.Name]

        if not Behavior then
            return
        end

        Behavior:OnUnequipped({
            State = self._ItemIdToToolState[Item.Id],
            Item = Item
        })

        self._EquippedToolItem = nil
        self._LastActivated = 0

        BehaviorMaid:DoCleaning()
    end)

    self._ToolServiceClient.Signals.ToolActivated:Connect(function()
        local Item = self._EquippedToolItem

        if not Item then
            return
        end

        local Behavior = self._ToolBehaviors[Item.Name]

        if not Behavior then
            return
        end

        if Item.Category ~= "Tool" then
            return 
        end

        local ToolConfig = ToolsConfig.Tools[Item.Name]

        if self._LastActivated + ToolConfig.Cooldown >= os.clock() then
            return
        end

        self._LastActivated = os.clock()

        Behavior:OnActivated({
            State = self._ItemIdToToolState[Item.Id],
            Item = Item
        })
    end)

    self._Maid:Add(self._InventoryServiceClient.Signals.ItemRemoved:Connect(function(itemId: ItemTypes.ItemId)
        self._ItemIdToToolState[itemId] = nil
    end))

    local EquipMaid = Maid.new()

    self._Maid:Add(Rx.combineLatest({
        Character = RxCharacterUtils.observeLocalPlayerCharacter(),
        Item = self._ToolbarServiceClient:ObserveEquippedItem(),
    }):Subscribe(function(data: any)
        EquipMaid:DoCleaning()

        local Item: ReactiveItemTypes.ReactiveItem? = data.Item
        local Character: Model? = data.Character
        
        if not Item or not Character then
            return
        end

        local ItemEquippableModel = AssetProvider:Get("Objects/Equippables/Watering Can")

        if not ItemEquippableModel then
            return
        end

        EquipMaid:Add(ItemEquippableModel)

        local RightHand = Character:WaitForChild("RightHand")
        local CharacterGripAttachment = RightHand:WaitForChild("RightGripAttachment") :: Attachment
        local ItemGripAttachment = ItemEquippableModel:WaitForChild("BoundingBox"):WaitForChild("GripAttachment") :: Attachment

        local RigidConstraint = EquipMaid:Add(Instance.new("RigidConstraint"))
        RigidConstraint.Attachment0 = CharacterGripAttachment
        RigidConstraint.Attachment1 = ItemGripAttachment
        RigidConstraint.Parent = ItemEquippableModel
        ItemEquippableModel.Parent = Character
    end))
end

return ToolsWorldClient :: Module