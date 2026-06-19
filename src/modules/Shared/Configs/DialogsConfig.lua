--[=[
    @class DialogsConfig

    Dialog content as a node graph, keyed by NPC. Each node is one line plus
    optional branching responses. Pure data - actions are declarative string
    keys resolved by the dialog action handler, never functions here.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type DialogAction = "OpenSeedShop" | "GiveDailyReward"

export type DialogResponse = {
    Text: string,
    Next: string?,
    Action: DialogAction?,
}

export type DialogNode = {
    Speaker: string,
    Text: string,
    Action: DialogAction?,
    Responses: { DialogResponse },
}

export type Dialog = {
    Start: string,
    Nodes: { [string]: DialogNode },
}

-- [ Module Table ] --
local DialogsConfig = {
    Dialogs = {
        GardenerJoe = {
            Start = "greet",
            Nodes = {
                greet = {
                    Speaker = "Gardener Joe",
                    Text = "Welcome to the garden! Looking to buy some seeds today?",
                    Responses = {
                        { Text = "Show me seeds", Next = "shop" },
                        { Text = "How do mutations work?", Next = "mutations" },
                        { Text = "Just looking", Next = nil },
                    },
                },
                shop = {
                    Speaker = "Gardener Joe",
                    Text = "Right this way!",
                    Action = "OpenSeedShop",
                    Responses = {},
                },
                mutations = {
                    Speaker = "Gardener Joe",
                    Text = "Weather decides what your plants become. Snow brings frost mutations!",
                    Responses = {
                        { Text = "Got it, show me seeds", Next = "shop" },
                        { Text = "Thanks!", Next = nil },
                    },
                },
            },
        },
    },
} :: {
    Dialogs: { [string]: Dialog },
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(DialogsConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return DialogsConfig :: Module
