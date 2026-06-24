--[=[
    @class GardenWorldClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local GardenTypesShared = require("GardenTypesShared")
local GardenTypesClient = require("GardenTypesClient")
local Rx = require("Rx")

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
    -- Walk ancestors until we hit a registered slot model. No depth cap: a
    -- plant model can nest more than one level under the slot, and the walk is
    -- O(tree depth) once per hover change — cheap and robust.
    while instance do
        local info = self._SlotModelToSlotInfo[instance]
        if info then
            return info
        end
        instance = instance.Parent
    end

    return nil
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
    self._Maid:Add(Rx.combineLatest({
        Model = self._MouseServiceClient:ObserveHoveredModel(),
        MainOpen = self._UIServiceClient:ObserveCategory("Main"),
    }):Pipe({
        Rx.map(function(data)
            if data.MainOpen then
                return
            end

            return self:_ResolveSlotInfo(data.Model)
        end) :: any,
        Rx.distinct() :: any,
    }):Subscribe(function(slotInfo)
        self._GardenServiceClient:HoverSlotInfo(slotInfo)
    end))

    self._Maid:Add(Rx.fromSignal(self._MouseServiceClient.Signals.MousePressed):Subscribe(function()
        self._GardenServiceClient:SelectSlotInfo(self._GardenServiceClient:GetHoveredSlotInfo())
    end))

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