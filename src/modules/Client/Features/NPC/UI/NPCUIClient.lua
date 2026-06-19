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
local Rx = require("Rx")
local Blend = require("Blend")

-- [ Components ] --
local GenericPromptComponent = require("GenericPromptComponent")

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
}

export type Module = typeof(NPCUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function NPCUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NPCServiceClient = self._ServiceBag:GetService(require("NPCServiceClient"))
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()
end

function NPCUIClient.Start(self: Module)
    self._Maid:Add(Blend.mount(self._UIServiceClient:GetScreen("Misc"), {
        GenericPromptComponent({
            Adornee = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.where(function(npc: NPCTypesClient.NPC?)
                    return npc ~= nil
                end) :: any,
                Rx.map(function(npc: NPCTypesClient.NPC)
                    return npc.Model.UIPoint
                end) :: any
            }) :: any,
            IsOpen = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.map(function(npc: NPCTypesClient.NPC?)
                    return npc ~= nil
                end) :: any
            }) :: any,
            Text = self._NPCServiceClient:ObserveClosestNPC():Pipe({
                Rx.map(function(npc: NPCTypesClient.NPC?)
                    return if not npc then "Get out of here boy" else "Speak to " .. npc.Name 
                end) :: any
            }) :: any,
            Use = function()

            end,
        })
    }))
end

return NPCUIClient :: Module