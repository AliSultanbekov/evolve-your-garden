--[=[
    @class UIZoneService
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local QuickZone = require("QuickZone")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UIZoneService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(UIZoneService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function UIZoneService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()
end

function UIZoneService.Start(self: Module)
    local UIZonesObserver = QuickZone.Observer.new({
        zones = { QuickZone.Zone.fromTag("UIZone") },
        groups = { QuickZone.Group.localPlayer() },
    })

    UIZonesObserver:onLocalPlayerEnter(function(zone: QuickZone.Zone)
        local ZoneInstance = zone:getReference()

        if not ZoneInstance then
            return
        end

        local UIName = ZoneInstance:GetAttribute("UIName") :: string

        self._UIServiceClient:OpenUI(UIName)
    end)

    UIZonesObserver:onLocalPlayerExit(function(zone: QuickZone.Zone)
        local ZoneInstance = zone:getReference()

        if not ZoneInstance then
            return
        end

        local UIName = ZoneInstance:GetAttribute("UIName") :: string

        self._UIServiceClient:CloseUI(UIName)
    end)
end

return UIZoneService :: Module