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
        QuestAdded: Signal.Signal<QuestsTypesShared.QuestAddedRemotePacket>,
        QuestCompleted: Signal.Signal<QuestsTypesShared.QuestCompletedRemotePacket>,
        RewardClaimed: Signal.Signal<QuestsTypesShared.RewardClaimedRemotePacket>,
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

function QuestsNetworkClient.ClaimReward(self: Module, packet: QuestsTypesShared.ClaimRewardRemotePacket)
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
        QuestAdded = Signal.new(),
        QuestCompleted = Signal.new(),
        RewardClaimed = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function QuestsNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:Connect("QuestAdded", function(packet: QuestsTypesShared.QuestAddedRemotePacket)
        self.RemoteEvents.QuestAdded:Fire(packet)
    end)

    Channel:Connect("QuestCompleted", function(packet: QuestsTypesShared.QuestCompletedRemotePacket)
        self.RemoteEvents.QuestCompleted:Fire(packet)
    end)

    Channel:Connect("RewardClaimed", function(packet: QuestsTypesShared.RewardClaimedRemotePacket)
        self.RemoteEvents.RewardClaimed:Fire(packet)
    end)
end

return QuestsNetworkClient :: Module
