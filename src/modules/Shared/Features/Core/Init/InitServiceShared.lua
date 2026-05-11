local RunService = game:GetService("RunService")
--[=[
    @class InitServiceShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --
local SINGLETONS = {
    "service",
    "manager",
    "network",
    "uiclient",
    "worldclient",
}

-- [ Variables ] --

-- [ Module Table ] --
local InitServiceShared = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
}

export type Module = typeof(InitServiceShared) & ModuleData

-- [ Private Functions ] --
function InitServiceShared._GetModules(self: Module)
    local ModulesFolder = script:FindFirstAncestor("Modules")
    local IsServer = RunService:IsServer()
    local Modules = {}

    local function handleDescendants(instance: any)
        if not instance:IsA("ModuleScript") then
            return
        end

        if instance.Name:lower() == "initserviceshared" then
            return
        end

        for _, name in SINGLETONS do
            if instance.Name:lower():find(name) then
                table.insert(Modules, instance)
                break
            end
        end
    end

    local Shared = ModulesFolder:FindFirstChild("Shared")

    for _, instance in Shared:GetDescendants() do
        handleDescendants(instance)
    end

    if IsServer then
        local Server = ModulesFolder:FindFirstChild("Server")

        for _, instance in Server:GetDescendants() do
            handleDescendants(instance)
        end
    else
        local Client = ModulesFolder:FindFirstChild("Client")

        for _, instance in Client:GetDescendants() do
            handleDescendants(instance)
        end
    end

    return Modules
end

-- [ Public Functions ] --
function InitServiceShared.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    print(self:_GetModules())

    for _, module in self:_GetModules() do
        self._ServiceBag:GetService(module)
    end
end

function InitServiceShared.Start(self: Module)

end

return InitServiceShared :: Module