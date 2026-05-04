--[=[
    @class BinderServiceShared
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local rbxrequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BinderServiceShared = {}

-- [ Types ] --
type ComponentModule = {
    Tag: string,
    new: (instance: Instance, serviceBag: ServiceBag.ServiceBag) -> any,
    Binded: (self: any) -> (),
    Unbinded: (self: any) -> (),
    Start: (binder: Binder.Binder<ComponentModule>, serviceBag: ServiceBag.ServiceBag) -> (),
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Components: { [string]: ComponentModule },
    _Binders: { [string]: Binder.Binder<ComponentModule> }
}

export type Module = typeof(BinderServiceShared) & ModuleData

-- [ Private Functions ] --
function BinderServiceShared._GetModules(self: Module)
    local ModulesFolder = script:FindFirstAncestor("Modules")
    local IsServer = RunService:IsServer()
    local Modules = {}

    local function handleDescendants(instance: any)
        if not instance:IsA("ModuleScript") then
            return
        end

        if not instance.Name:lower():find("component") then
            return
        end

        table.insert(Modules, instance)
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

function BinderServiceShared._CreateBinder(self: Module, module: ComponentModule, serviceBag: ServiceBag.ServiceBag)
    local BinderObject = Binder.new(
        module.Tag, 
        function(instance)
            return module.new(instance, serviceBag)
        end
    )

    return serviceBag:GetService(BinderObject)
end

-- [ Public Functions ] --
function BinderServiceShared.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Components = {}
    self._Binders = {}

    for _, instance in self:_GetModules() do
        local ComponentModule: ComponentModule = rbxrequire(instance)

        self._Components[ComponentModule.Tag] = ComponentModule
        self._Binders[ComponentModule.Tag] = self:_CreateBinder(ComponentModule, self._ServiceBag)
    end
end

function BinderServiceShared.Start(self: Module)
    for tag, binder in pairs(self._Binders) do
        local Component = self._Components[tag]

        task.spawn(Component.Start, binder, self._ServiceBag)

        local function onAdded(obj: ComponentModule)
            if obj.Binded then
                task.spawn(obj.Binded, obj)
            end
        end

        local function onRemoved(obj: ComponentModule)
            if obj.Unbinded then
                task.spawn(obj.Unbinded, obj)
            end
        end

        binder:GetClassAddedSignal():Connect(onAdded)
        binder:GetClassRemovedSignal():Connect(onRemoved)
    end
end

return BinderServiceShared :: Module