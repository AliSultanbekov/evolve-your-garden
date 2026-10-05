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
export type QuestState = "Active" | "Completed" | "Burnt"
export type QuestCategory = "Primary" | "Encyclopedia"
export type RequirementId = string
export type QuestRequirement = {
    Id: RequirementId,
    Source: QuestSource,
    Key: string,
    GoalType: QuestGoalType,
    Goal: number,
}

export type QuestConfig = {
    Id: QuestId,
    Type: QuestType,
    Category: QuestCategory,
    Reward: {
        [string]: ItemTypes.RawItem
    },
    Requirements: {
        [string]: QuestRequirement
    }
}

export type Quest = {
    Id: QuestId,
    StartTime: number,
    State: QuestState,
    Anchors: {[string]: number},
}

export type QuestsData = {
    [QuestId]: Quest
}

export type QuestsRemovedRemotePacket = {
    QuestIds: { [any]: QuestId }
}

export type QuestsAddedRemotePacket = {
    Quests: { [any]: Quest }
}

export type QuestsUpdatedRemotePacket = {
    Quests: { [any]: Quest }
}

export type QuestClaimRewardRemotePacket = {
    QuestId: QuestId
}

export type GetQuestsRemotePacket = {
    Quests: QuestsData
}

return nil