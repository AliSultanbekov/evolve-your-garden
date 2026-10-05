--[=[
    @class QuestsServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local QuestsTypesShared = require("QuestsTypesShared")
local QuestsTypesClient = require("QuestsTypesClient")
local QuestsConfig = require("QuestsConfig")
local ObservableMap = require("ObservableMap")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestsServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _QuestsNetworkClient: typeof(require("QuestsNetworkClient")),
    _Quests: QuestsTypesClient.Quests,
    _StateToQuests: {
        [QuestsTypesShared.QuestState]: QuestsTypesClient.Quests
    },
    _CategoryToQuests: {
        [QuestsTypesShared.QuestCategory]: QuestsTypesClient.Quests
    }
}

export type Module = typeof(QuestsServiceClient) & ModuleData

-- [ Private Functions ] --
function QuestsServiceClient._SetupStateToQuests(self: Module)
    return {
        Active = ObservableMap.new(),
        Completed = ObservableMap.new(),
        Burnt = ObservableMap.new()
    }
end

function QuestsServiceClient._SetupCategoryToQuests(self: Module)
    local CategoryToQuests = {} :: {
        [QuestsTypesShared.QuestCategory]: QuestsTypesClient.Quests
    }

    for _, category: QuestsTypesShared.QuestCategory in QuestsConfig.Categories do
        CategoryToQuests[category] = ObservableMap.new()
    end

    return CategoryToQuests
end

function QuestsServiceClient._AddQuest(self: Module, quest: QuestsTypesShared.Quest)
    local QuestConfig = QuestsConfig.Quests[quest.Id]

    if not QuestConfig then
        warn(`[QuestsServiceClient] No config for quest "{quest.Id}" - skipping`)
        return
    end

    local ReactiveQuest = self:_ToReactiveQuest(quest)

    self._Quests:Set(quest.Id, ReactiveQuest)
    self._StateToQuests[quest.State]:Set(quest.Id, ReactiveQuest)
    self._CategoryToQuests[QuestConfig.Category]:Set(quest.Id, ReactiveQuest)
end

function QuestsServiceClient._RemoveQuest(self: Module, questId: QuestsTypesShared.QuestId)
    local ReactiveQuest = self._Quests:Get(questId)

    if not ReactiveQuest then
        return
    end

    self._Quests:Remove(questId)
    self._StateToQuests[ReactiveQuest.State.Value]:Remove(questId)

    local QuestConfig = QuestsConfig.Quests[questId]

    if QuestConfig then
        self._CategoryToQuests[QuestConfig.Category]:Remove(questId)
    end
end

function QuestsServiceClient._ToReactiveQuest(self: Module, quest: QuestsTypesShared.Quest): QuestsTypesClient.ReactiveQuest
    return {
        Id = quest.Id,
        State = ValueObject.new(quest.State) :: any,
        StartTime = quest.StartTime,
        Anchors = quest.Anchors,
    }
end

function QuestsServiceClient._SyncQuestFromPlain(self: Module, reactiveQuest: QuestsTypesClient.ReactiveQuest, plainQuest: QuestsTypesShared.Quest)
    local StaleState: QuestsTypesShared.QuestState = reactiveQuest.State.Value

    reactiveQuest.State.Value = plainQuest.State

    if StaleState ~= plainQuest.State then
        self._StateToQuests[StaleState]:Remove(plainQuest.Id)
        self._StateToQuests[plainQuest.State]:Set(plainQuest.Id, reactiveQuest)
    end
end

function QuestsServiceClient._ProcessQuests(self: Module, quests: { [any]: QuestsTypesShared.Quest })
    for _, quest in quests do
        self:_AddQuest(quest)
    end
end

-- [ Public Functions ] --
function QuestsServiceClient.GetQuests(self: Module)
    return self._Quests
end

function QuestsServiceClient.GetQuestsByState(self: Module, state: QuestsTypesShared.QuestState)
    return self._StateToQuests[state]
end

function QuestsServiceClient.GetQuestsByCategory(self: Module, category: QuestsTypesShared.QuestCategory)
    return self._CategoryToQuests[category]
end

function QuestsServiceClient.ClaimReward(self: Module, questId: QuestsTypesShared.QuestId)
    self._QuestsNetworkClient:ClaimReward({
        QuestId = questId
    })
end

function QuestsServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._QuestsNetworkClient = self._ServiceBag:GetService(require("QuestsNetworkClient"))
    self._Quests = ObservableMap.new()
    self._StateToQuests = self:_SetupStateToQuests()
    self._CategoryToQuests = self:_SetupCategoryToQuests()
end

function QuestsServiceClient.Start(self: Module)
    self._QuestsNetworkClient:GetQuests():Then(function(packet: QuestsTypesShared.GetQuestsRemotePacket)
        self:_ProcessQuests(packet.Quests)
    end)

    self._QuestsNetworkClient.RemoteEvents.QuestsAdded:Connect(function(packet: QuestsTypesShared.QuestsAddedRemotePacket)
        for _, quest in packet.Quests do
            self:_AddQuest(quest)
        end
    end)

    self._QuestsNetworkClient.RemoteEvents.QuestsRemoved:Connect(function(packet: QuestsTypesShared.QuestsRemovedRemotePacket)
        for _, questId in packet.QuestIds do
            self:_RemoveQuest(questId)
        end
    end)

    self._QuestsNetworkClient.RemoteEvents.QuestsUpdated:Connect(function(packet: QuestsTypesShared.QuestsUpdatedRemotePacket)
        for _, quest in packet.Quests do
            local ReactiveQuest = self._Quests:Get(quest.Id)

            if not ReactiveQuest then
                continue
            end

            self:_SyncQuestFromPlain(ReactiveQuest, quest)
        end
    end)
end

return QuestsServiceClient :: Module