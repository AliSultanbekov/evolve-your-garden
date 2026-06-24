--[=[
    @class NPCUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local NPCTypesClient = require("NPCTypesClient")
local NPCTypesShared = require("NPCTypesShared")
local Rx = require("Rx")
local DialogsConfig = require("DialogsConfig")
local ValueObject = require("ValueObject")

-- [ Components ] --
local GenericPromptComponent = require("GenericPromptComponent")
local DialogWindow = require(script.Parent.Components.Dialog._Window)
local Speech = require(script.Parent.Components._Speech)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NPCUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NPCServiceClient: typeof(require("NPCServiceClient")),
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
    _NPCSpeaking: ValueObject.ValueObject<boolean>
}

export type Module = typeof(NPCUIClient) & ModuleData

-- [ Private Functions ] --
function NPCUIClient._GetActiveTopic(self: Module, npcName: string, topicId: NPCTypesShared.TopicId)
    return DialogsConfig.Dialogs[npcName].Topics[topicId]
end

function NPCUIClient._UseAction(self: Module, action: string)
    if action == "OpenUI_PackStore" then
        self._UIServiceClient:OpenUI("PackStore")
    end
end

-- [ Public Functions ] --
function NPCUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NPCServiceClient = self._ServiceBag:GetService(require("NPCServiceClient"))
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()
    self._NPCSpeaking = ValueObject.new(false)
end

function NPCUIClient.Start(self: Module)
    local ActiveTopic = Rx.combineLatest({
        TopicId = self._NPCServiceClient:ObserveActiveTopicId(),
        NPC = self._NPCServiceClient:ObserveClosestNPC(),
    }):Pipe({
        Rx.where(function(data): boolean
            return data.TopicId ~= nil and data.NPC ~= nil
        end) :: any,
        Rx.map(function(data)
            return self:_GetActiveTopic(data.NPC.Name, data.TopicId)
        end) :: any,
        Rx.shareReplay(1) :: any,
    })

    self._Maid:Add(Rx.combineLatest({
        Topic = ActiveTopic,
        Speaking = self._NPCSpeaking:Observe(),
    }):Pipe({
        Rx.scan(function(acc, data)
            return {
                Topic = data.Topic,
                Speaking = data.Speaking,
                WasSpeaking = if not acc then false elseif acc.Speaking == nil then false else acc.Speaking,
            }
        end, { Topic = nil, Speaking = nil, WasSpeaking = false }) :: any,
        Rx.where(function(state): boolean
            return state.WasSpeaking == true and state.Speaking == false
        end) :: any,
    }):Subscribe(function(state)
        if state.Topic and state.Topic.Action then
            self:_UseAction(state.Topic.Action)
        end

        if not next(state.Topic.Responses) then
            self._NPCServiceClient:SetActiveTopicId(nil)
        end
    end))

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        GenericPromptComponent({
            Adornee = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.where(function(npc: NPCTypesClient.NPC?)
                    return npc ~= nil
                end) :: any,
                Rx.map(function(npc: NPCTypesClient.NPC)
                    return npc.Model.UIPoint
                end) :: any
            }) :: any,
            IsOpen = Rx.combineLatest({
                ClosestNPC = self._NPCServiceClient:ObserveClosestNPC(),
                ActiveTopicId = self._NPCServiceClient:ObserveActiveTopicId(),
            }):Pipe({
                Rx.map(function(data)
                    return data.ClosestNPC ~= nil and not data.ActiveTopicId
                end) :: any,
            }) :: any,
            Text = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.map(function(npc: NPCTypesClient.NPC?)
                    return if not npc then "Get out of here boy" else "Speak to " .. npc.Name 
                end) :: any
            }) :: any,
            Use = function()
                local ClosestNPC = self._NPCServiceClient:GetClosestNPC()

                if not ClosestNPC then
                    return
                end

                local StartTopicId = DialogsConfig.Dialogs[ClosestNPC.Name].StartTopicId

                self._NPCServiceClient:SetActiveTopicId(StartTopicId)
            end,
        }),

        DialogWindow({
            IsOpen = Rx.combineLatest({
                ActiveTopicId = self._NPCServiceClient:ObserveActiveTopicId(),
                NPCSpeaking = self._NPCSpeaking:Observe(),
            }):Pipe({
                Rx.map(function(data)
                    return data.ActiveTopicId ~= nil and not data.NPCSpeaking
                end) :: any
            }) :: any,
            Adornee = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.where(function(npc: NPCTypesClient.NPC): boolean
                    return npc ~= nil
                end) :: any,
                Rx.map(function(npc: NPCTypesClient.NPC)
                    return npc.Model.UIPoint
                end) :: any
            }) :: any,
            ChooseResponse = function(response: NPCTypesShared.Response)  
                local ClosestNPC = self._NPCServiceClient:GetClosestNPC()

                if not ClosestNPC then
                    return
                end

                local ActiveTopicId = self._NPCServiceClient:GetActiveTopicId()

                if not ActiveTopicId then
                    return
                end

                local ActiveTopic = self:_GetActiveTopic(ClosestNPC.Name, ActiveTopicId)

                if not ActiveTopic.Responses[response.Id] then
                    return
                end

                self._NPCServiceClient:SetActiveTopicId(response.NextTopicId)
            end,
            Topic = ActiveTopic :: any,
        }),

        Speech({
            Adornee = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.where(function(npc: NPCTypesClient.NPC): boolean
                    return npc ~= nil
                end) :: any,
                Rx.map(function(npc: NPCTypesClient.NPC)
                    return npc.Model.UIPoint
                end) :: any
            }) :: any,
            IsOpen = Rx.combineLatest({
                ActiveTopicId = self._NPCServiceClient:ObserveActiveTopicId(),
                NPCSpeaking = self._NPCSpeaking:Observe(),
            }):Pipe({
                Rx.map(function(data)
                    return data.ActiveTopicId ~= nil and data.NPCSpeaking
                end) :: any
            }) :: any,
            Text = (ActiveTopic :: any):Pipe({
                Rx.map(function(topic: NPCTypesShared.Topic)
                    return topic.Text
                end)
            }) :: any,
            OnSpeakingChanged = function(value: boolean)
                self._NPCSpeaking.Value = value
            end
        })
    } end))
end

return NPCUIClient :: Module