
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
local GardenComponent = require(script.Parent.Garden._GardenComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenServiceClient: typeof(require("GardenServiceClient")),
    _PortalServiceClient: typeof(require("PortalServiceClient")),
    _MouseServiceClient: typeof(require("MouseServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(GardenWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenServiceClient = self._ServiceBag:GetService(require("GardenServiceClient"))
    self._PortalServiceClient = self._ServiceBag:GetService(require("PortalServiceClient"))
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._Maid = Maid.new()
end

function GardenWorldClient.Start(self: Module)
    local Gardens = self._GardenServiceClient:GetGardens()
    local GardensFolder = workspace.World.Gardens
    
    for _, garden in pairs(Gardens) do
        local GardenFolder = GardensFolder:FindFirstChild(garden.GardenId) :: GardenTypesClient.GardenFolder?

        if not GardenFolder then
            warn(string.format("[GardenWorldClient] Could not find GardenFolder for GardenId: %s", tostring(garden.GardenId)))
            continue
        end

        local FirstPortalId = self._PortalServiceClient:RegisterPortal(GardenFolder.Portal, nil, nil)
    
        self._Maid:Add(garden.Owner:Observe():Pipe({
            Rx.scan(function(acc, userId: string?)
                return { Previous = if acc then acc.Previous else nil, Current = userId}
            end, { Previous = nil, Current = nil}) :: any,
            Rx.where(function(data: { Previous: string?, Current: string})
                return data.Current ~= data.Previous
            end) :: any,
        }):Subscribe(function(data: { Previous: string?, Current: string})
            if data.Previous then
                self._PortalServiceClient:Unwhitelist(FirstPortalId, data.Previous)
            end

            if data.Current then
                self._PortalServiceClient:Whitelist(FirstPortalId, data.Current)
            end
        end))

        self._Maid:Add(GardenComponent({
            MouseServiceClient = self._MouseServiceClient;

            Garden = garden;
            SelectedSlot = self._GardenServiceClient:ObserveSelectedSlot();
            
            OnSlotHovered = function(slotId: GardenTypesShared.SlotId)
                self._GardenServiceClient:HoverSlot(slotId)
            end,
            OnSlotUnhovered = function(slotId: GardenTypesShared.SlotId)
                self._GardenServiceClient:HoverSlot(nil)
            end,
            OnSlotSelected = function(slotId: GardenTypesShared.SlotId)
                self._GardenServiceClient:SelectSlot(slotId)
            end,
            OnSlotCreated = function(slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel)
                self._GardenServiceClient:RegisterSlotModel(slotId, slotModel)
            end,
            OnSlotDestroyed = function(slotId: GardenTypesShared.SlotId)
                self._GardenServiceClient:UnregisterSlotModel(slotId)
            end,
            OnGardenModelCreated = function(GardenModel: GardenTypesClient.GardenModel)
                local PortalModel = GardenModel.Portal
                local SecondPortalId = self._PortalServiceClient:RegisterPortal(PortalModel, nil, FirstPortalId)
                self._PortalServiceClient:UpdateTarget(FirstPortalId, SecondPortalId)
            end
        }))
    end
end

return GardenWorldClient :: Module