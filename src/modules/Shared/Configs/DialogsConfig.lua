--[=[
    @class DialogsConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local NPCTypesShared = require("NPCTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DialogsConfig = {}

-- [ Private Functions ] --
function DialogsConfig._Init(self: Module)
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

export type Module = typeof(DialogsConfig) & ModuleData

(DialogsConfig :: any):_Init()

return DialogsConfig :: Module