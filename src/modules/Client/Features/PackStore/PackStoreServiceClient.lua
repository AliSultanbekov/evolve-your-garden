--[=[
    @class PackStoreServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")
local PackStoreTypesClient = require("PackStoreTypesClient")
local PackStoreTypesShared = require("PackStoreTypesShared")
local PackStoreUtil = require("PackStoreUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PackStoreNetworkClient: typeof(require("PackStoreNetworkClient")),
    _CurrentSale: {
        StartTime: ValueObject.ValueObject<number>,
        Packs: PackStoreTypesClient.Packs
    }
}

export type Module = typeof(PackStoreServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PackStoreServiceClient.BuyPack(self: Module, packId: PackStoreTypesShared.PackId)
    self._PackStoreNetworkClient:BuyPack({ PackId = packId })
end

function PackStoreServiceClient.GetPacks(self: Module)
    return self._CurrentSale.Packs
end

function PackStoreServiceClient.UpdatePacks(self: Module, packs: PackStoreTypesShared.Packs, startTime: number)
    for _, key in self._CurrentSale.Packs:GetKeyList() do
        self._CurrentSale.Packs:Remove(key)
    end

    for _, pack in packs do
        self._CurrentSale.Packs:Set(pack.Id, PackStoreUtil:ToReactive(pack))
    end
end

function PackStoreServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PackStoreNetworkClient = self._ServiceBag:GetService(require("PackStoreNetworkClient"))
    self._CurrentSale = {
        StartTime = ValueObject.new(),
        Packs = ObservableMap.new(),
    }
end

function PackStoreServiceClient.Start(self: Module)
    self._PackStoreNetworkClient:GetCurrentSale():Then(function(packet: PackStoreTypesShared.GetCurrentSaleRemotePacket)
        self:UpdatePacks(packet.Packs, packet.StartTime)
    end)

    self._PackStoreNetworkClient.RemoteEvents.Refreshed:Connect(function(packet: PackStoreTypesShared.RefreshedRemotePacket)
        self:UpdatePacks(packet.Packs, packet.StartTime)
    end)

    self._PackStoreNetworkClient.RemoteEvents.PackBought:Connect(function(packet: PackStoreTypesShared.PackBoughtRemotePacket)
        local Pack = self._CurrentSale.Packs:Get(packet.PackId)

        if not Pack then
            return
        end

        Pack.Left.Value -= 1
    end)
end

return PackStoreServiceClient :: Module