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
        ClaimReward: Signal.Signal<Player, QuestsTypesShared.QuestClaimRewardRemotePacket>,
    },
    RemoteFunctions: {
        GetQuests: (player: Player) -> QuestsTypesShared.GetQuestsRemotePacket
    }
}

export type Module = typeof(QuestsNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function QuestsNetworkServer.QuestsAdded(self: Module, player: Player, packet: QuestsTypesShared.QuestsAddedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireClient("QuestsAdded", player, packet)
end

function QuestsNetworkServer.QuestsUpdated(self: Module, player: Player, packet: QuestsTypesShared.QuestsUpdatedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireClient("QuestsUpdated", player, packet)
end

function QuestsNetworkServer.QuestsRemoved(self: Module, player: Player, packet: QuestsTypesShared.QuestsRemovedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Quests")

    Channel:FireClient("QuestsRemoved", player, packet)
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
    Channel:DeclareEvent("QuestsAdded")
    Channel:DeclareEvent("QuestsUpdated")
    Channel:DeclareEvent("QuestsRemoved")
    Channel:DeclareEvent("ClaimReward")

    Channel:Bind("GetQuests", function(player: Player)
        return self.RemoteFunctions.GetQuests(player)
    end)

    Channel:Connect("ClaimReward", function(player: Player, packet: QuestsTypesShared.QuestClaimRewardRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.QuestId) ~= "string" then
            return
        end

        self.RemoteEvents.ClaimReward:Fire(player, packet)
    end)
end

return QuestsNetworkServer :: Module
