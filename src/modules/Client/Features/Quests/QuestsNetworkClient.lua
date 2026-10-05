--[=[
    @class QuestsNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local QuestsTypesShared = require("QuestsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestsNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        QuestsAdded: Signal.Signal<QuestsTypesShared.QuestsAddedRemotePacket>,
        QuestsUpdated: Signal.Signal<QuestsTypesShared.QuestsUpdatedRemotePacket>,
        QuestsRemoved: Signal.Signal<QuestsTypesShared.QuestsRemovedRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(QuestsNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function QuestsNetworkClient.GetQuests(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    return Channel:PromiseInvokeServer("GetQuests")
end

function QuestsNetworkClient.ClaimReward(self: Module, packet: QuestsTypesShared.QuestClaimRewardRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireServer("ClaimReward", packet)
end

function QuestsNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        QuestsAdded = Signal.new(),
        QuestsUpdated = Signal.new(),
        QuestsRemoved = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function QuestsNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:Connect("QuestsAdded", function(packet: QuestsTypesShared.QuestsAddedRemotePacket)
        self.RemoteEvents.QuestsAdded:Fire(packet)
    end)

    Channel:Connect("QuestsUpdated", function(packet: QuestsTypesShared.QuestsUpdatedRemotePacket)
        self.RemoteEvents.QuestsUpdated:Fire(packet)
    end)

    Channel:Connect("QuestsRemoved", function(packet: QuestsTypesShared.QuestsRemovedRemotePacket)
        self.RemoteEvents.QuestsRemoved:Fire(packet)
    end)
end

return QuestsNetworkClient :: Module
