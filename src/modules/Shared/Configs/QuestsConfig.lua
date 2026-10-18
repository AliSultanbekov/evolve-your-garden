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
            Description = "Play for 1h",
            Type = "OneTime",
            Category = "Encyclopedia",
            Rewards = {
                ["Fruit"] = {
                    Name = "Fruit",
                    Category = "Material",
                }
            },
            Requirements = {
                ["1"] = { 
                    Id = "1", 
                    Source = "Stats", 
                    Key = "PlayTime", 
                    GoalType = "Absolute", 
                    Goal = 60 
                }
            }
        },
        ["Repeat Quest"] = {
            Id = "Cool Quest",
            Description = "Play for 1h",
            Type = "Repeatable",
            Category = "Encyclopedia",
            Rewards = {
                ["Fruit"] = {
                    Name = "Fruit",
                    Category = "Material",
                }
            },
            Requirements = {
                ["1"] = { 
                    Id = "1", 
                    Source = "Stats", 
                    Key = "PlayTime", 
                    GoalType = "Absolute", 
                    Goal = 60
                }
            }
        }
    }
    self.AutoActiveQuests = {"Cool Quest", "Repeat Quest"}
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