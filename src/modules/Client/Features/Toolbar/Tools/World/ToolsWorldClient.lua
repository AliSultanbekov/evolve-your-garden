--[=[
    @class ToolsWorldClient

    Tool visuals only: welds the equipped item's model to the character.
    Behavior, state and activation live in ToolServiceClient.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Maid = require("Maid")
local RxCharacterUtils = require("RxCharacterUtils")
local Rx = require("Rx")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _Maid: Maid.Maid,
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
    self._Maid = Maid.new()
end

function ToolsWorldClient.Start(self: Module)
    local EquipMaid = self._Maid:Add(Maid.new())

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
