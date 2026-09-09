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
    _EncyclopediaServiceServer: typeof(require("EncyclopediaServiceServer"))
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

function QuestsServiceServer.ClaimReward(self: Module, player: Player, questId: QuestTypesShared.QuestId)
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

    self._InventoryServiceServer:AddRawItems(player, QuestConfig.Reward)
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
end

function QuestsServiceServer.Start(self: Module)
    self._StatsServiceServer.Signals.StatUpdated:Connect(function(player: Player, stat: string, newValue: number)
        self:ProcessQuestsViaChange(player, "Stats", stat, newValue)
    end)

    self._EncyclopediaServiceServer.Signals.ItemDiscovered:Connect(function(player: Player, itemName: string, totalAcquired: number)
        self:ProcessQuestsViaChange(player, "Stats", itemName, totalAcquired)
    end)
end

return QuestsServiceServer :: Module