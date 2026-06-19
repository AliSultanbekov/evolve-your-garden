

--[=[
    @class NPCServiceClient
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local NPCTypesClient = require("NPCTypesClient")
local ObservableMap = require("ObservableMap")
local ValueObject = require("ValueObject")
local Maid = require("Maid")
local NPCConfigClient = require("NPCConfigClient")

-- [ Constants ] --

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local NPCServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _NPCs: NPCTypesClient.NPCs,
    _ClosestNPC: ValueObject.ValueObject<NPCTypesClient.NPC?>
}

export type Module = typeof(NPCServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function NPCServiceClient.GetClosestNPC(self: Module)
    return self._ClosestNPC.Value
end

function NPCServiceClient.ObserveClosestNPC(self: Module)
    return self._ClosestNPC:Observe()
end

function NPCServiceClient.RegisterNPC(self: Module, model: Model, name: string)
    local NPCId = HttpService:GenerateGUID(false)

    self._NPCs:Set(NPCId, {
        Id = NPCId,
        Model = model,
        Name = name
    })

    return NPCId
end

function NPCServiceClient.UnregisterNPC(self: Module, id: NPCTypesClient.NPCId)
    self._NPCs:Remove(id)
end

function NPCServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._NPCs = ObservableMap.new()
    self._ClosestNPC = ValueObject.new()
end

function NPCServiceClient.Start(self: Module)
    self._Maid:Add(RunService.Heartbeat:Connect(function()
        local Character = LocalPlayer.Character

        if not Character then
            self._ClosestNPC.Value = nil
            return
        end

        local CharacterPosition = Character:GetPivot().Position
        local ClosestNPC: NPCTypesClient.NPC? = nil
        local ClosestDistance = math.huge

        for _, npc: NPCTypesClient.NPC in pairs(self._NPCs:GetValueList()) do
            local Distance = (npc.Model:GetPivot().Position - CharacterPosition).Magnitude

            if Distance <= NPCConfigClient.Range and Distance < ClosestDistance then
                ClosestDistance = Distance
                ClosestNPC = npc
            end
        end

        self._ClosestNPC.Value = ClosestNPC
    end))
end

return NPCServiceClient :: Module