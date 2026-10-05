--[=[
    @class QuestTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local QuestsTypesShared = require("QuestsTypesShared")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ReactiveQuest = {
    Id: QuestsTypesShared.QuestId,
    StartTime: number,
    State: ValueObject.ValueObject<QuestsTypesShared.QuestState>,
    Anchors: {[string]: number},
}

export type Quests = ObservableMap.ObservableMap<QuestsTypesShared.QuestId, ReactiveQuest>

return nil