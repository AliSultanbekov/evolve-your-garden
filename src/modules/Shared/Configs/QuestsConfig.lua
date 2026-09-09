--[=[
    @class QuestConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local QuestsTypesShared = require("QuestsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestConfig = {}

-- [ Private Functions ] --
function QuestConfig._Init(self: Module)
    self.Quests = {
        ["Cool Quest"] = {
            Id = "Cool Quest",
            Type = "OneTime",
            Reward = {
                ["Snow Blossom Fruit"] = {
                    Name = "Snow Blossom Fruit",
                    Category = "Material",
                }
            },
            Source = "Stats",
            Key = "PlayTime",
            GoalType = "Absolute",
            Goal = 60 * 60,
        }
    }
    self.AutoActiveQuests = {
        "Cool Quest",
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Quests: {
        [QuestsTypesShared.QuestId]: QuestsTypesShared.QuestConfig
    },
    AutoActiveQuests: { QuestsTypesShared.QuestId }
}

export type Module = typeof(QuestConfig) & ModuleData

(QuestConfig :: any):_Init()

return QuestConfig :: Module