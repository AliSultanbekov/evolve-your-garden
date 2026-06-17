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

local GardenComponent = require(script.Parent.Garden._GardenComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenServiceClient: typeof(require("GardenServiceClient")),
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
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._Maid = Maid.new()
end

function GardenWorldClient.Start(self: Module)
    local Gardens = self._GardenServiceClient:GetGardens()

    for _, garden in pairs(Gardens) do
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
            end
        }))
    end
end

return GardenWorldClient :: Module