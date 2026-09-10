--[=[
    @class QuestsServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local QuestTypesShared = require("QuestsTypesShared")
local QuestsConfig = require("QuestsConfig")
local RxPlayerUtils = require("RxPlayerUtils")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestsServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    _StatsServiceServer: typeof(require("StatsServiceServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _EncyclopediaServiceServer: typeof(require("EncyclopediaServiceServer")),
    _QuestsNetworkServer: typeof(require("QuestsNetworkServer"))
}

export type Module = typeof(QuestsServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function QuestsServiceServer.GetSourceInfo(self: Module, player: Player, source: QuestTypesShared.QuestSource, key: string): number
    if source == "Encyclopedia" then
        return self._EncyclopediaServiceServer:GetTotalAcquired(player, key)
    elseif source == "Stats" then
        return self._StatsServiceServer:GetStat(player, key)
    end

    error("[QuestsServiceServer] Unsupported quest source: Stats")
end

function QuestsServiceServer.ProcessQuestsViaChange(
    self: Module, 
    player: Player, 
    source: QuestTypesShared.QuestSource,
    key: string, 
    newValue: number
)
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests

    for _, quest in QuestsData.Active do
        local QuestId = quest.Id
        local QuestConfig = QuestsConfig.Quests[quest.Id]
        
        if quest.GoalType == "Absolute" then
            if newValue < QuestConfig.Goal then
                continue
            end
        elseif quest.GoalType == "Relative" then
            if newValue - quest.Anchor < QuestConfig.Goal then
                continue
            end
        end

        QuestsData.Active[QuestId] = nil
        QuestsData.Completed[QuestId] = true
    end
end

function QuestsServiceServer.AddQuest(self: Module, player: Player, questId: QuestTypesShared.QuestId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests

    if QuestsData.Burnt[questId] then
        return
    end

    if QuestsData.Active[questId] then
        return
    end

    if QuestsData.Completed[questId] then
        return
    end

    local QuestConfig = QuestsConfig.Quests[questId]

    local Quest = {} :: QuestTypesShared.Quest

    if QuestConfig.GoalType == "Absolute" then
        Quest = {
            Id = questId,
            GoalType = "Absolute",
            StartTime = DateTime.now().UnixTimestamp
        }
    elseif QuestConfig.GoalType == "Relative" then
        Quest = {
            Id = questId,
            GoalType = "Relative",
            StartTime = DateTime.now().UnixTimestamp,
            Anchor = self:GetSourceInfo(player, QuestConfig.Source, QuestConfig.Key)
        }
    end

    QuestsData.Active[questId] = Quest

    -- fire
end

function QuestsServiceServer.ClaimQuestReward(self: Module, player: Player, questId: QuestTypesShared.QuestId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests

    if QuestsData.Burnt[questId] then
        return
    end

    if not QuestsData.Completed[questId] then
        return
    end

    local QuestConfig = QuestsConfig.Quests[questId]

    if QuestConfig.Type == "OneTime" then
        QuestsData.Burnt[questId] = true
    end

    QuestsData.Completed[questId] = nil

    self._InventoryServiceServer:AddRawItems(player, QuestConfig.Reward, true)
end

function QuestsServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._StatsServiceServer = self._ServiceBag:GetService(require("StatsServiceServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._EncyclopediaServiceServer = self._ServiceBag:GetService(require("EncyclopediaServiceServer"))
    self._QuestsNetworkServer = self._ServiceBag:GetService(require("QuestsNetworkServer"))
end

function QuestsServiceServer.Start(self: Module)
    self._QuestsNetworkServer.RemoteFunctions["GetQuests"] = function(player: Player)
        local PlayerData = self._DataServiceServer:GetData(player)

        return PlayerData.Quests
    end

    self._QuestsNetworkServer.RemoteEvents.ClaimReward:Connect(function(player: Player, packet: QuestTypesShared.ClaimRewardRemotePacket)
        self:ClaimQuestReward(player, packet.QuestId)
    end)

    self._StatsServiceServer.Signals.StatUpdated:Connect(function(player: Player, stat: string, newValue: number)
        self:ProcessQuestsViaChange(player, "Stats", stat, newValue)
    end)

    self._EncyclopediaServiceServer.Signals.ItemDiscovered:Connect(function(player: Player, itemName: string, totalAcquired: number)
        self:ProcessQuestsViaChange(player, "Stats", itemName, totalAcquired)
    end)
    
    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local Maid, Player = brio:ToMaidAndValue()

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(data)
            local QuestsData = data.Quests

            for _, questId in QuestsConfig.AutoActiveQuests do
                if QuestsData.Active[questId] then
                    continue
                end

                if QuestsData.Burnt[questId] then
                    continue
                end
                
                self:AddQuest(Player, questId)
            end

            return
        end))
    end)
end

return QuestsServiceServer :: Module