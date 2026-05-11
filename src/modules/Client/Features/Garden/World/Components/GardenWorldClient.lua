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

local GardenComponent = require(script.Parent.Garden._Garden)

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
    
    local OnSlotSelected = function(slotId: GardenTypesShared.SlotId)
        self._GardenServiceClient:SelectSlot(slotId)
    end

    for _, garden in pairs(Gardens) do
        self._Maid:Add(GardenComponent({
            Garden = garden,
            MouseServiceClient = self._MouseServiceClient,
            OnSlotSelected = OnSlotSelected
        }))
    end
end

return GardenWorldClient :: Module