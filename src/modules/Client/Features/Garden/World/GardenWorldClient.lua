--[=[
    @class GardenWorldClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local GardenTypesClient = require("GardenTypesClient")
local Rx = require("Rx")
local RxCharacterUtils = require("RxCharacterUtils")
local RangeUtil = require("RangeUtil")
local GardenConfigClient = require("GardenConfigClient")
local GardenTypesShared = require("GardenTypesShared")

-- [ Components ] --
local GardenComponent = require(script.Parent.Components._GardenComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenServiceClient: typeof(require("GardenServiceClient")),
    _MouseServiceClient: typeof(require("MouseServiceClient")),
    _PortalServiceClient: typeof(require("PortalServiceClient")),
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
    _SlotModelToSlotInfo: { [Instance]: GardenTypesClient.SlotInfo },
}

export type Module = typeof(GardenWorldClient) & ModuleData

-- [ Private Functions ] --
function GardenWorldClient._ResolveSlotInfo(self: Module, instance: Instance?): GardenTypesClient.SlotInfo?
    while instance do
        local info = self._SlotModelToSlotInfo[instance]
        if info then
            return info
        end
        instance = instance.Parent
    end

    return nil
end

function GardenWorldClient._SetupHover(self: Module)
    self._Maid:Add(Rx.combineLatest({
        IsMainOpen = self._UIServiceClient:ObserveCategory("Main"),
        Character = RxCharacterUtils.observeLocalPlayerCharacter(),
        Model = self._MouseServiceClient:ObserveHoveredModel()
    }):Pipe({
        Rx.map(function(data: any)
            if data.IsMainOpen then
                return
            end

            if self._GardenServiceClient:GetSelectedSlotInfo() then
                return
            end

            local SlotInfo = self:_ResolveSlotInfo(data.Model)
            
            if not SlotInfo then
                return
            end
            
            local SlotModel = self._GardenServiceClient:GetSlotModel(SlotInfo.GardenId, SlotInfo.SlotId)

            if not SlotModel then
                return
            end

            if not data.Character then
                return
            end

            if not RangeUtil:CheckModelRange(SlotModel, data.Character, GardenConfigClient.InteractionRange) then
                return
            end

            return SlotInfo
        end) :: any,
        Rx.distinct() :: any,
    }):Subscribe(function(slotInfo: GardenTypesClient.SlotInfo?)
        self._GardenServiceClient:HoverSlotInfo(slotInfo)
    end))
end

function GardenWorldClient._SetupSelect(self: Module)
    self._Maid:Add(Rx.fromSignal(self._MouseServiceClient.Signals.MousePressed :: any):Subscribe(function(pressedInstance: Instance?)
        if self._UIServiceClient:IsCategoryOpen("Main") then
            return
        end

        if self._GardenServiceClient:GetSelectedSlotInfo() then
            return
        end

        local Character = Players.LocalPlayer.Character

        if not Character then
            return
        end

        local SlotInfo = self:_ResolveSlotInfo(pressedInstance)

        if not SlotInfo then
            return
        end

        local SlotModel = self._GardenServiceClient:GetSlotModel(SlotInfo.GardenId, SlotInfo.SlotId)

        if not SlotModel then
            return
        end

        if not RangeUtil:CheckModelRange(SlotModel, Character, GardenConfigClient.InteractionRange) then
            return
        end

        self._GardenServiceClient:SelectSlotInfo(SlotInfo)
    end))
end

-- [ Public Functions ] --
function GardenWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenServiceClient = self._ServiceBag:GetService(require("GardenServiceClient"))
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._PortalServiceClient = self._ServiceBag:GetService(require("PortalServiceClient"))
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()
    self._SlotModelToSlotInfo = {}
end

function GardenWorldClient.Start(self: Module)
    self:_SetupHover()
    self:_SetupSelect()

    for _, garden in pairs(self._GardenServiceClient:GetGardens()) do
        local OutsidePortalId = self._PortalServiceClient:RegisterPortal(workspace.World.Gardens[garden.Id]["Portal"])

        self._Maid:Add(GardenComponent({
            Garden = garden,

            OnGardenCreated = function(gardenModel: GardenTypesClient.GardenModel)
                self._GardenServiceClient:RegisterGardenModel(garden.Id, gardenModel)

                local InsidePortalId = self._PortalServiceClient:RegisterPortal(gardenModel.Portal, nil, OutsidePortalId)

                self._PortalServiceClient:UpdateTarget(OutsidePortalId, InsidePortalId)
            end,
            OnGardenDestroyed = function()
                self._GardenServiceClient:UnregisterGardenModel(garden.Id)
            end,
            OnSlotCreated = function(slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel)
                self._GardenServiceClient:RegisterSlotModel(garden.Id, slotId, slotModel)

                self._SlotModelToSlotInfo[slotModel] = {
                    SlotId = slotId,
                    GardenId = garden.Id
                }
            end,
            OnSlotDestroyed = function(slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel)
                self._GardenServiceClient:UnregisterSlotModel(garden.Id, slotId)

                self._SlotModelToSlotInfo[slotModel] = nil
            end
        }))
    end
end

return GardenWorldClient :: Module