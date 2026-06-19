
--[=[
    @class NPCTypesClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type NPCParams = {
    Name: string,
}
export type NPCId = string
export type NPCModel = typeof(ReplicatedStorage.TypeExamples.NPC)
export type NPC = {
    Id: NPCId,
    Model: NPCModel,
    Name: string,
}
export type NPCs = ObservableMap.ObservableMap<NPCId, NPC>

return nil