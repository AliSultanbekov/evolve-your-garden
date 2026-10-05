--[=[
    @class QuestsServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local QuestsTypesShared = require("QuestsTypesShared")
local QuestsConfig = require("QuestsConfig")
local RxPlayerUtils = require("RxPlayerUtils")
local PlayerToUserId = require("PlayerToUserId")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestsServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _QuestsNetworkServer: typeof(require("QuestsNetworkServer")),
    _DataServiceServer: typeof(require("DataServiceServer")),
    _StatsServiceServer: typeof(require("StatsServiceServer")),
    _EncyclopediaServiceServer: typeof(require("EncyclopediaServiceServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _PlayersStateToQuestIds: {
        [string]: {
            Active: { [QuestsTypesShared.QuestId]: boolean },
            Completed: { [QuestsTypesShared.QuestId]: boolean },
            Burnt: { [QuestsTypesShared.QuestId]: boolean },
        }
    },
    _SourceKeyToQuestIds: {
        [string]: { 
            [QuestsTypesShared.QuestId]: boolean
        } 
    }
}

export type Module = typeof(QuestsServiceServer) & ModuleData

-- [ Private Functions ] --
function QuestsServiceServer._GetSourceInfo(self: Module, player: Player, source: QuestsTypesShared.QuestSource, key: string): number
    if source == "Encyclopedia" then
        return self._EncyclopediaServiceServer:GetTotalAcquired(player, key)
    elseif source == "Stats" then
        return self._StatsServiceServer:GetStat(player, key)
    end

    error("[QuestsServiceServer] Unsupported quest source: Stats")
end

function QuestsServiceServer._SetupAnchors(self: Module, player: Player, questId: QuestsTypesShared.QuestId)
    local Anchors = {}

    local QuestConfig = QuestsConfig.Quests[questId]

    for _, requirement in QuestConfig.Requirements do
        if requirement.GoalType == "Absolute" then
            continue
        end

        Anchors[requirement.Id] = self:_GetSourceInfo(player, requirement.Source, requirement.Key)
    end

    return Anchors
end

-- [ Public Functions ] --
function QuestsServiceServer.ProcessQuestsViaChange(
    self: Module, 
    player: Player, 
    source: QuestsTypesShared.QuestSource,
    key: string, 
    newValue: number
)
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local SourceKey = source .. key
    local QuestsToClaim = {}

    for questId, _ in pairs(self._SourceKeyToQuestIds[SourceKey]) do
        local Quest = QuestsData[questId]
        local QuestConfig = QuestsConfig.Quests[questId]

        for _, requirement in QuestConfig.Requirements do
            if requirement.Source ~= source and requirement.Key ~= key then
                continue
            end

            if requirement.GoalType == "Relative" then
                newValue -= Quest.Anchors[requirement.Id]
            end

            if newValue < requirement.Goal then
                continue
            end
            
            table.insert(QuestsToClaim, Quest.Id)
        end
    end

    self:ClaimQuestsRewards(player, QuestsToClaim)
end

function QuestsServiceServer.ClaimQuestsRewards(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId })
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local UserId = PlayerToUserId(player)
    local StateToQuestIds = self._PlayersStateToQuestIds[UserId]

    local QuestsToUpdate = {}
    local QuestIdsToDelete = {}

    for _, questId in questIds do
        local Quest = QuestsData[questId]

        if not Quest then
            return
        end

        if Quest.State ~= "Completed" then
            return
        end

        local QuestConfig = QuestsConfig.Quests[questId]

        self._InventoryServiceServer:AddRawItems(player, QuestConfig.Reward, true)

        if QuestConfig.Type == "OneTime" then
            Quest.State = "Burnt"
            StateToQuestIds.Completed[questId] = nil
            StateToQuestIds.Burnt[questId] = true
            table.insert(QuestsToUpdate, Quest)
        else
            QuestsData[questId] = nil
            StateToQuestIds.Completed[questId] = nil
            table.insert(QuestIdsToDelete, questId)
        end
    end

    if next(QuestsToUpdate) == nil then
        self._QuestsNetworkServer:QuestsUpdated(player, {
            Quests = QuestsToUpdate
        })
    end

    if next(QuestIdsToDelete) == nil then
        self._QuestsNetworkServer:QuestsRemoved(player, {
            QuestIds = QuestIdsToDelete
        })
    end
end

function QuestsServiceServer.AddQuest(self: Module, player: Player, questId: QuestsTypesShared.QuestId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests

    if QuestsData[questId] then
        return
    end

    local Quest: QuestsTypesShared.Quest = {
        Id = questId,
        StartTime = DateTime.now().UnixTimestamp,
        State = "Active",
        Anchors = self:_SetupAnchors(player, questId)
    }

    QuestsData[questId] = Quest

    self._QuestsNetworkServer:QuestsAdded(player, {
        Quests = { Quest }
    })
end

function QuestsServiceServer.RemoveQuest(self: Module, player: Player, questId: QuestsTypesShared.QuestId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local UserId = PlayerToUserId(player)
    local StateToQuestIds = self._PlayersStateToQuestIds[UserId]
    local Quest = QuestsData[questId]

    if not Quest then
        return
    end

    QuestsData[questId] = nil
    StateToQuestIds[Quest.State][Quest.Id] = nil

    self._QuestsNetworkServer:QuestsRemoved(player, {
        QuestIds = { questId }
    })
end

function QuestsServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._QuestsNetworkServer = self._ServiceBag:GetService(require("QuestsNetworkServer"))
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._StatsServiceServer = self._ServiceBag:GetService(require("StatsServiceServer"))
    self._EncyclopediaServiceServer = self._ServiceBag:GetService(require("EncyclopediaServiceServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._PlayersStateToQuestIds = {}
    self._SourceKeyToQuestIds = {}
end

function QuestsServiceServer.Start(self: Module)
    self._QuestsNetworkServer.RemoteFunctions["GetQuests"] = function(player: Player)
        local PlayerData = self._DataServiceServer:GetData(player)

        return {
            Quests = PlayerData.Quests
        }
    end

    self._QuestsNetworkServer.RemoteEvents.ClaimReward:Connect(function(player: Player, packet: QuestsTypesShared.QuestClaimRewardRemotePacket)
        self:ClaimQuestsRewards(player, { packet.QuestId })
    end)

    self._StatsServiceServer.Signals.StatUpdated:Connect(function(player: Player, stat: string, newValue: number)
        self:ProcessQuestsViaChange(player, "Stats", stat, newValue)
    end)

    self._EncyclopediaServiceServer.Signals.ItemDiscovered:Connect(function(player: Player, itemName: string, totalAcquired: number)
        self:ProcessQuestsViaChange(player, "Encyclopedia", itemName, totalAcquired)
    end)

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local Maid, Player = brio:ToMaidAndValue()
        local UserId = PlayerToUserId(Player)

        self._PlayersStateToQuestIds[UserId] = {
            Active = {},
            Completed = {},
            Burnt = {},
        }

        for _, quest in QuestsConfig.Quests do
            for _, requirement in quest.Requirements do
                local SourceKey = requirement.Source .. requirement.Key

                if not self._SourceKeyToQuestIds[SourceKey] then
                    self._SourceKeyToQuestIds[SourceKey] = {}
                end

                self._SourceKeyToQuestIds[SourceKey][quest.Id] = true
            end
        end

        Maid:Add(function()
            self._PlayersStateToQuestIds[UserId] = nil
        end)

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(data)
            local QuestsData = data.Quests
            local StateToQuestIds = self._PlayersStateToQuestIds[UserId]

            for _, quest in QuestsData do
                StateToQuestIds[quest.State][quest.Id] = true
            end

            for _, questId in QuestsConfig.AutoActiveQuests do
                if QuestsData[questId] then
                    continue
                end
                
                self:AddQuest(Player, questId)
            end

            return
        end))
    end)
end

return QuestsServiceServer :: Module