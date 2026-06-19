
--[=[
    @class NPCWorldClient
]=]

-- [ Roblox Services ] --
local CollectionService = game:GetService("CollectionService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NPCWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NPCServiceClient: typeof(require("NPCServiceClient")),
    _Maid: Maid.Maid
}

export type Module = typeof(NPCWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function NPCWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NPCServiceClient = self._ServiceBag:GetService(require("NPCServiceClient"))
    self._Maid = Maid.new()
end

function NPCWorldClient.Start(self: Module)
    local function OnAdded(npcModel: Model)
        local Name = npcModel:GetAttribute("Name") :: string?
        if not Name then
            return
        end

        local NPCId = self._NPCServiceClient:RegisterNPC(npcModel, Name)

        self._Maid[npcModel] = function()
            self._NPCServiceClient:UnregisterNPC(NPCId)
        end
    end

    local function OnRemoved(npcModel: Model)
        self._Maid[npcModel] = nil
    end

    self._Maid:Add(CollectionService:GetInstanceAddedSignal("NPC"):Connect(OnAdded))
    self._Maid:Add(CollectionService:GetInstanceRemovedSignal("NPC"):Connect(OnRemoved))

    for _, npcModel in CollectionService:GetTagged("NPC") do
        OnAdded(npcModel)
    end
end

return NPCWorldClient :: Module