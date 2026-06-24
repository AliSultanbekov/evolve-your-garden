--[=[
    @class HUDUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Components ] --
local ButtonsWindow = require(script.Parent.Components.Buttons._ButtonsWindow)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HUDUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(HUDUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()

    self._UIServiceClient:RegisterUI({
        UIName = "HUDButtons",
        Category = "HUD",
        Conflicts = {}
    })
end

function HUDUIClient.Start(self: Module)
    self._UIServiceClient:OpenUI("HUDButtons")

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        ButtonsWindow({
            IsOpen = self._UIServiceClient:ObserveUI("HUDButtons"),
            OnToggleUI = function(uiName: string)
                self._UIServiceClient:ToggleUI(uiName)
            end
        })
    } end))
end

return HUDUIClient :: Module