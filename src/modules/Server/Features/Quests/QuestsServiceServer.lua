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
function QuestsServiceServer._SetupAnchors(self: Module, player: Player, questId: QuestsTypesShared.QuestId)
    local Anchors = {}

    local QuestConfig = QuestsConfig.Quests[questId]

    for _, requirement in QuestConfig.Requirements do
        if requirement.GoalType == "Absolute" then
            continue
        end

        Anchors[requirement.Id] = self:GetRequirementValue(player, requirement)
    end

    return Anchors
end

function QuestsServiceServer._UpdateQuestState(self: Module, player: Player, questId: QuestsTypesShared.QuestId, state: QuestsTypesShared.QuestState): QuestsTypesShared.Quest
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local UserId = PlayerToUserId(player)
    local StateToQuestIds = self._PlayersStateToQuestIds[UserId]
    local Quest = QuestsData[questId]

    if not Quest then
        error(string.format("[QuestsServiceServer] Quest does not exist for id: %s", tostring(questId)))
    end

    local StaleState = Quest.State
    
    Quest.State = state
    
    StateToQuestIds[StaleState][Quest.Id] = nil
    StateToQuestIds[state][Quest.Id] = true

    return Quest
end

function QuestsServiceServer._UpdateQuestsState(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId }, state: QuestsTypesShared.QuestState)
    local Quests = {}
    
    for _, questId in questIds do
        table.insert(Quests, self:_UpdateQuestState(player, questId, state))
    end

    return Quests
end

-- [ Public Functions ] --
function QuestsServiceServer.GetRequirementValue(self: Module, player: Player, requirement: QuestsTypesShared.QuestRequirement): number
    if requirement.Source == "Encyclopedia" then
        return self._EncyclopediaServiceServer:GetTotalAcquired(player, requirement.Key)
    elseif requirement.Source == "Stats" then
        return self._StatsServiceServer:GetStat(player, requirement.Key)
    end

    error("[QuestsServiceServer] Unsupported quest source: Stats")
end

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
    local QuestsToComplete = {}
    local QuestIds = self._SourceKeyToQuestIds[SourceKey]

    if not QuestIds then
        return
    end

    for questId, _ in QuestIds do
        local Quest = QuestsData[questId]

        if not Quest then
            continue
        end

        local QuestConfig = QuestsConfig.Quests[questId]

        for _, requirement in QuestConfig.Requirements do
            if requirement.Source ~= source or requirement.Key ~= key then
                continue
            end

            local Value = newValue

            if requirement.GoalType == "Relative" then
                Value -= Quest.Anchors[requirement.Id]
            end
            
            if Value < requirement.Goal then
                continue
            end
            
            table.insert(QuestsToComplete, Quest.Id)
        end
    end

    self:CompleteQuests(player, QuestsToComplete)
end

function QuestsServiceServer.ClaimQuestsRewards(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId })
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests

    local QuestIdsToBurn = {}
    local QuestIdsToRemove = {}

    for _, questId in questIds do
        local Quest = QuestsData[questId]

        if not Quest then
            continue
        end

        if Quest.State ~= "Completed" then
            continue
        end

        local QuestConfig = QuestsConfig.Quests[questId]

        self._InventoryServiceServer:AddRawItems(player, QuestConfig.Rewards, true)

        if QuestConfig.Type == "OneTime" then
            table.insert(QuestIdsToBurn, questId)
        else
            table.insert(QuestIdsToRemove, questId)
        end
    end

    self:UpdateQuests(player, self:_UpdateQuestsState(player, QuestIdsToBurn, "Burnt"))
    self:RemoveQuests(player, QuestIdsToRemove)
end

function QuestsServiceServer.TryCompleteQuests(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId })
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local QuestIdsToComplete = {}

    for _, questId in questIds do
        local Quest = QuestsData[questId]

        if not Quest then
            continue
        end

        local QuestConfig = QuestsConfig.Quests[questId]
        

        for _, requirement in QuestConfig.Requirements do
            local RequirementValue = self:GetRequirementValue(player, requirement)

            if requirement.GoalType == "Relative" then
                RequirementValue -= Quest.Anchors[requirement.Id]
            end
            
            if RequirementValue < requirement.Goal then
                continue
            end
            
            table.insert(QuestIdsToComplete, Quest.Id)
        end
    end

    if next(QuestIdsToComplete) ~= nil then
        self:CompleteQuests(player, QuestIdsToComplete)
    end
end

function QuestsServiceServer.CompleteQuests(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId })
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local QuestIdsToComplete = {}

    for _, questId in questIds do
        local Quest = QuestsData[questId]

        if not Quest then
            continue
        end

        if Quest.State ~= "Active" then
            continue
        end

        table.insert(QuestIdsToComplete, questId)
    end

    self:UpdateQuests(player, self:_UpdateQuestsState(player, QuestIdsToComplete, "Completed"))
end

function QuestsServiceServer.AddQuests(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId })
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local UserId = PlayerToUserId(player)
    local StateToQuestIds = self._PlayersStateToQuestIds[UserId]
    local AddedQuests = {}

    for _, questId in questIds do
        if QuestsData[questId] then
            continue
        end

        local Quest: QuestsTypesShared.Quest = {
            Id = questId,
            StartTime = DateTime.now().UnixTimestamp,
            State = "Active",
            Anchors = self:_SetupAnchors(player, questId)
        }

        QuestsData[questId] = Quest
        StateToQuestIds.Active[questId] = true

        table.insert(AddedQuests, Quest)
    end

    if next(AddedQuests) ~= nil then
        self._QuestsNetworkServer:QuestsAdded(player, {
            Quests = AddedQuests
        })
    end
end

function QuestsServiceServer.UpdateQuests(
    self: Module,
    player: Player,
    quests: { [any]: QuestsTypesShared.Quest }
)
    for _, quest in quests do
        self:_UpdateQuestState(player, quest.Id, quest.State)
    end

    self._QuestsNetworkServer:QuestsUpdated(player, {
        Quests = quests
    })
end

function QuestsServiceServer.RemoveQuests(self: Module, player: Player, questIds: { [any]: QuestsTypesShared.QuestId })
    local PlayerData = self._DataServiceServer:GetData(player)
    local QuestsData = PlayerData.Quests
    local UserId = PlayerToUserId(player)
    local StateToQuestIds = self._PlayersStateToQuestIds[UserId]
    local RemovedQuestIds = {}

    for _, questId in questIds do
        local Quest = QuestsData[questId]

        if not Quest then
            continue
        end

        QuestsData[questId] = nil
        StateToQuestIds[Quest.State][questId] = nil

        table.insert(RemovedQuestIds, questId)
    end

    if next(RemovedQuestIds) ~= nil then
        self._QuestsNetworkServer:QuestsRemoved(player, {
            QuestIds = RemovedQuestIds
        })
    end
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

    for _, quest in QuestsConfig.Quests do
        for _, requirement in quest.Requirements do
            local SourceKey = requirement.Source .. requirement.Key

            if not self._SourceKeyToQuestIds[SourceKey] then
                self._SourceKeyToQuestIds[SourceKey] = {}
            end

            self._SourceKeyToQuestIds[SourceKey][quest.Id] = true
        end
    end

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local Maid, Player = brio:ToMaidAndValue()
        local UserId = PlayerToUserId(Player)

        self._PlayersStateToQuestIds[UserId] = {
            Active = {},
            Completed = {},
            Burnt = {},
        }       

        Maid:Add(function()
            self._PlayersStateToQuestIds[UserId] = nil
        end)

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(data)
            local QuestsData = data.Quests
            local StateToQuestIds = self._PlayersStateToQuestIds[UserId]

            local QuestIds = {}

            for _, quest in QuestsData do
                StateToQuestIds[quest.State][quest.Id] = true
                table.insert(QuestIds, quest.Id)
            end

            local QuestIdsToAdd = {}

            for _, questId in QuestsConfig.AutoActiveQuests do
                if QuestsData[questId] then
                    continue
                end

                table.insert(QuestIdsToAdd, questId)
            end

            self:AddQuests(Player, QuestIdsToAdd)

            self:TryCompleteQuests(Player, QuestIds)
            self:TryCompleteQuests(Player, QuestIdsToAdd)

            return
        end))
    end)
end

return QuestsServiceServer :: Module