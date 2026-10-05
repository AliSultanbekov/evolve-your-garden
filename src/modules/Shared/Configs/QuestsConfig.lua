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
            Category = "Encyclopedia",
            Reward = {
                ["Snow Blossom Fruit"] = {
                    Name = "Snow Blossom Fruit",
                    Category = "Material",
                }
            },
            Requirements = {
                ["1"] = { 
                    Id = "1", 
                    Source = "Stats", 
                    Key = "PlayTime", 
                    GoalType = "Absolute", 
                    Goal = 60 * 60 
                }
            }
        }
    }
    self.AutoActiveQuests = {"Cool Quest"}
    self.Categories = {"Primary", "Encyclopedia"}
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Quests: {
        [QuestsTypesShared.QuestId]: QuestsTypesShared.QuestConfig
    },
    AutoActiveQuests: { QuestsTypesShared.QuestId },
    Categories: { QuestsTypesShared.QuestCategory }
}

export type Module = typeof(QuestConfig) & ModuleData

(QuestConfig :: any):_Init()

return QuestConfig :: Module