
--[=[
    @class PortalWorldClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Brio = require("Brio")
local Maid = require("Maid")
local PortalTypesClient = require("PortalTypesClient")

-- [ Components ] --
local PortalComponent = require(script.Parent.Components._Portal)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PortalWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PortalServiceClient: typeof(require("PortalServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(PortalWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PortalWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PortalServiceClient = self._ServiceBag:GetService(require("PortalServiceClient"))
    self._Maid = Maid.new()
end

function PortalWorldClient.Start(self: Module)
    self._Maid:Add(self._PortalServiceClient:GetPortals():ObserveValuesBrio():Subscribe(function(brio: Brio.Brio<PortalTypesClient.Portal>)
        local PortalMaid: Maid.Maid, Portal: PortalTypesClient.Portal = brio:ToMaidAndValue()

        PortalMaid:Add(PortalComponent({
            Model = Portal.Model
        }))
    end))
end

return PortalWorldClient :: Module