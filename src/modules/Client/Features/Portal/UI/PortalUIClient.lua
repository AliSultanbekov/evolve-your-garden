--[=[
    @class PortalUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Rx = require("Rx")
local PortalTypesClient = require("PortalTypesClient")

-- [ Components ] --
local GenericPromptComponent = require("GenericPromptComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PortalUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _PortalServiceClient: typeof(require("PortalServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(PortalUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PortalUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._PortalServiceClient = self._ServiceBag:GetService(require("PortalServiceClient"))
    self._Maid = Maid.new()
end

function PortalUIClient.Start(self: Module)
    local Adornee = self._PortalServiceClient:ObserveClosestPortal():Pipe({
        Rx.where(function(portal: PortalTypesClient.Portal?)
            return portal ~= nil
        end) :: any,
        Rx.map(function(portal: PortalTypesClient.Portal)
            return portal.Model.UIPoint
        end) :: any,
    })

    local IsOpen = self._PortalServiceClient:ObserveClosestPortal():Pipe({
        Rx.map(function(portal: PortalTypesClient.Portal?)
            return portal ~= nil
        end) :: any,
    })

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        GenericPromptComponent({
            Adornee = Adornee :: any,
            IsOpen = IsOpen :: any,
            Text = "Teleport",
            Use = function()
                local Portal = self._PortalServiceClient:GetClosestPortal()

                if not Portal then
                    return
                end

                self._PortalServiceClient:Use(Portal.Id)
            end,
        })
    } end))
end

return PortalUIClient :: Module