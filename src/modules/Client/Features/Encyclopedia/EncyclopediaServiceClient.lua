--[=[
    @class EncyclopediaServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local PlantsConfig = require("PlantsConfig")
local EncyclopediaTypesShared = require("EncyclopediaTypesShared")
local EncyclopediaTypesClient = require("EncyclopediaTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EncyclopediaServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EncyclopediaNetworkClient: typeof(require("EncyclopediaNetworkClient")),
    _DiscoveredItems: {
        [string]: EncyclopediaTypesClient.ReactiveDiscoveredItem
    },
    _DiscoveredPlantsCount: ValueObject.ValueObject<number>
}

export type Module = typeof(EncyclopediaServiceClient) & ModuleData

-- [ Private Functions ] --
function EncyclopediaServiceClient._SetupDiscoveredItems(self: Module)
    local DiscoveredItems = {}

    for _, plantConfig in PlantsConfig.Plants do
        DiscoveredItems[plantConfig.Name] = {
            DiscoveredTime = ValueObject.new(nil),
            TotalAcquired = ValueObject.new(0)
        }
    end

    return DiscoveredItems
end

-- [ Public Functions ] --
function EncyclopediaServiceClient.ObserveDiscoveredPlantsCount(self: Module)
    return self._DiscoveredPlantsCount:Observe()
end

function EncyclopediaServiceClient.GetDiscoveredItem(self: Module, itemName: string)
    return self._DiscoveredItems[itemName]
end

function EncyclopediaServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EncyclopediaNetworkClient = self._ServiceBag:GetService(require("EncyclopediaNetworkClient"))
    self._DiscoveredItems = self:_SetupDiscoveredItems()
    self._DiscoveredPlantsCount = ValueObject.new(0)
end

function EncyclopediaServiceClient.Start(self: Module)
    self._EncyclopediaNetworkClient:GetDiscoveredItems():Then(function(packet: EncyclopediaTypesShared.GetDiscoveredItemsRemotePacket)
        for itemName, discoveredItem in packet.DiscoveredItems do
            self._DiscoveredItems[itemName].DiscoveredTime.Value = discoveredItem.DiscoveredTime
            self._DiscoveredItems[itemName].TotalAcquired.Value = discoveredItem.TotalAcquired

            if PlantsConfig.Plants[itemName] and discoveredItem.TotalAcquired > 0 then
                self._DiscoveredPlantsCount.Value += 1
            end
        end
    end)
end

return EncyclopediaServiceClient :: Module