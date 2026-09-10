--[=[
    @class QuestsNetworkServer
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
local QuestsNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        ClaimReward: Signal.Signal<Player, QuestsTypesShared.ClaimRewardRemotePacket>,
    },
    RemoteFunctions: {
        GetQuests: (player: Player) -> QuestsTypesShared.GetQuestsRemotePacket
    }
}

export type Module = typeof(QuestsNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function QuestsNetworkServer.QuestAdded(self: Module, player: Player, packet: QuestsTypesShared.QuestAddedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireClient("QuestAdded", player, packet)
end

function QuestsNetworkServer.QuestCompleted(self: Module, player: Player, packet: QuestsTypesShared.QuestCompletedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireClient("QuestCompleted", player, packet)
end

function QuestsNetworkServer.RewardClaimed(self: Module, player: Player, packet: QuestsTypesShared.RewardClaimedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireClient("RewardClaimed", player, packet)
end

function QuestsNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        ClaimReward = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function QuestsNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:DeclareMethod("GetQuests")
    Channel:DeclareEvent("QuestAdded")
    Channel:DeclareEvent("QuestCompleted")
    Channel:DeclareEvent("RewardClaimed")
    Channel:DeclareEvent("ClaimReward")

    Channel:Bind("GetQuests", function(player: Player)
        return self.RemoteFunctions.GetQuests(player)
    end)

    Channel:Connect("ClaimReward", function(player: Player, packet: QuestsTypesShared.ClaimRewardRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.QuestId) ~= "string" then
            return
        end

        self.RemoteEvents.ClaimReward:Fire(player, packet)
    end)
end

return QuestsNetworkServer :: Module
