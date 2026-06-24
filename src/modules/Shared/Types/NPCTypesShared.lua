--[=[
    @class NPCTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type TopicId = string
export type ResponseId = string

export type Response = {
    Id: ResponseId,
    Text: string,
    NextTopicId: TopicId?,
    Action: string?,
}

export type Topic = {
    Id: TopicId,
    Text: string,
    Responses: { [ResponseId]: Response },
    Action: string?,
}

export type NPCDialog = {
    StartTopicId: TopicId,
    Topics: { [TopicId]: Topic }
}


return nil