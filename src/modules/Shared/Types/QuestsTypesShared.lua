--[=[
    @class QuestsTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type QuestId = string
export type QuestType = "OneTime" | "Repeatable"
export type QuestSource = "Encyclopedia" | "Stats"
export type QuestGoalType = "Relative" | "Absolute"

export type EncyclopediaQuestConfig = {
    Id: QuestId,
    Type: QuestType,
    Reward: {
        [string]: ItemTypes.RawItem
    },
    Source: "Encyclopedia",
    Key: string,
    GoalType: QuestGoalType,
    Goal: number,
}

export type StatsQuestConfig = {
    Id: QuestId,
    Type: QuestType,
    Reward: {
        [string]: ItemTypes.RawItem
    },
    Source: "Stats",
    Key: string,
    GoalType: QuestGoalType,
    Goal: number,
}

export type QuestConfig = EncyclopediaQuestConfig | StatsQuestConfig

export type RelativeQuest = {
    Id: QuestId,
    GoalType: "Relative",
    StartTime: number,
    Anchor: number,
}

export type AbsoluteQuest = {
    Id: QuestId,
    GoalType: "Absolute",
    StartTime: number,
}

export type Quest = AbsoluteQuest | RelativeQuest

export type QuestsData = {
    Active: {
        [QuestId]: Quest
    },
    Completed: {
        [QuestId]: boolean
    },
    Burnt: {
        [QuestId]: boolean
    },
}

export type QuestAddedRemotePacket = {
    Quest: Quest
}

export type QuestCompletedRemotePacket = {
    QuestId: QuestId
}

export type RewardClaimedRemotePacket = {
    QuestId: QuestId
}

export type ClaimRewardRemotePacket = {
    QuestId: QuestId
}

export type GetQuestsRemotePacket = QuestsData

return nil