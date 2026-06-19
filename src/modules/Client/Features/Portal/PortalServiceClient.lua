--[=[
    @class PortalServiceClient
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local PortalTypesClient = require("PortalTypesClient")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")
local PortalConfigClient = require("PortalConfigClient")

-- [ Constants ] --

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local PortalServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Portals: PortalTypesClient.Portals,
    _ClosestPortal: ValueObject.ValueObject<PortalTypesClient.Portal?>
}

export type Module = typeof(PortalServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PortalServiceClient.Whitelisted(self: Module, portalId: PortalTypesClient.PortalId, userId: string): boolean
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return false
    end

    return Portal.Whitelist[userId] ~= nil
end

function PortalServiceClient.Whitelist(self: Module, portalId: PortalTypesClient.PortalId, userId: string)
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return
    end

    Portal.Whitelist[userId] = true
end

function PortalServiceClient.Unwhitelist(self: Module, portalId: PortalTypesClient.PortalId, userId: string)
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return
    end

    Portal.Whitelist[userId] = nil
end

function PortalServiceClient.Use(self: Module, portalId: PortalTypesClient.PortalId)
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return
    end

    if not Portal.Target.Value then
        return
    end

    local TargetPortal = self._Portals:Get(Portal.Target.Value)

    if not TargetPortal then
        return
    end

    local Character = LocalPlayer.Character

    if not Character then
        return
    end

    Character:PivotTo(TargetPortal.Model.TeleportPoint.WorldCFrame)
end

function PortalServiceClient.GetClosestPortal(self: Module)
    return self._ClosestPortal.Value
end

function PortalServiceClient.ObserveClosestPortal(self: Module)
    return self._ClosestPortal:Observe()
end

function PortalServiceClient.GetPortals(self: Module)
    return self._Portals
end

function PortalServiceClient.ObserveTarget(self: Module, portalId: PortalTypesClient.PortalId)
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return
    end

    return Portal.Target:Observe()
end

function PortalServiceClient.UpdateTarget(self: Module, portalId: PortalTypesClient.PortalId, target: PortalTypesClient.PortalId?)
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return
    end

    Portal.Target.Value = target

    if not target then
        Portal.Maid._TargetWatch = nil
        return
    end

    Portal.Maid._TargetWatch = self._Portals:ObserveAtKey(target):Subscribe(function(portal: PortalTypesClient.Portal?)
        if not portal then
            Portal.Target.Value = nil
        end
    end)
end

function PortalServiceClient.RegisterPortal(self: Module, model: Model, whitelist: { [string]: boolean }?, target: PortalTypesClient.PortalId?): PortalTypesClient.PortalId
    local PortalId = HttpService:GenerateGUID(false)

    local Portal = {
        Whitelist = whitelist or {},
        Id = PortalId,
        Model = model,
        Maid = Maid.new(),
        Target = ValueObject.new(target),
    }

    self._Portals:Set(PortalId, Portal)

    return PortalId
end

function PortalServiceClient.UnregisterPortal(self: Module, portalId: PortalTypesClient.PortalId)
    local Portal = self._Portals:Get(portalId)

    if not Portal then
        return
    end

    Portal.Maid:DoCleaning()
    self._Portals:Remove(portalId)
end

function PortalServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Portals = ObservableMap.new()
    self._ClosestPortal = ValueObject.new()
end

function PortalServiceClient.Start(self: Module)
    self._Maid:Add(RunService.Heartbeat:Connect(function()
        local Character = LocalPlayer.Character

        if not Character then
            self._ClosestPortal.Value = nil
            return
        end

        local CharacterPosition = Character:GetPivot().Position
        local ClosestPortal: PortalTypesClient.Portal? = nil
        local ClosestDistance = math.huge

        for _, portal: PortalTypesClient.Portal in pairs(self._Portals:GetValueList()) do
            local Distance = (portal.Model:GetPivot().Position - CharacterPosition).Magnitude

            if Distance <= PortalConfigClient.Range and Distance < ClosestDistance then
                ClosestDistance = Distance
                ClosestPortal = portal
            end
        end

        self._ClosestPortal.Value = ClosestPortal
    end))
end

return PortalServiceClient :: Module