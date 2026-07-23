--[=[
    @class NPCsConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local NPCTypesShared = require("NPCTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NPCsConfig = {}

-- [ Private Functions ] --
function NPCsConfig._Init(self: Module)
    self.Dialogs = {
        ["Bob"] = {
            StartTopicId = "Start",
            Topics = {
                ["Start"] = {
                    Id = "Start",
                    Text = "Hello there!",
                    Responses = {
                        ["1"] = {
                            Id = "1",
                            Text = "Show me what you got in stock",
                            NextTopicId = "ShowStore"
                        }
                    }
                },
                ["ShowStore"] = {
                    Id = "ShowStore",
                    Text = "Alright, here!",
                    Action = "OpenUI_PackStore",
                    Responses = {},
                }
            }
        },
        ["Martin"] = {
            StartTopicId = "Start",
            Topics = {
                ["Start"] = {
                    Id = "Start",
                    Text = "Hello there!",
                    Responses = {
                        ["1"] = {
                            Id = "1",
                            Text = "Let me just look around",
                            NextTopicId = "ShowStore"
                        }
                    }
                },
                ["ShowStore"] = {
                    Id = "ShowStore",
                    Text = "Alright, here!",
                    Action = "OpenUI_Merchant",
                    Responses = {},
                }
            }
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Dialogs: {
        [string]: NPCTypesShared.NPCDialog
    }
}

export type Module = typeof(NPCsConfig) & ModuleData

(NPCsConfig :: any):_Init()

return NPCsConfig :: Module