--[=[
    @class ToolbarUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ToolbarTypesShared = require("ToolbarTypesShared")

-- [ Components ] --
local ToolbarComponent = require(script.Parent.Components.ToolbarComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(ToolbarUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolbarUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarServiceClient = self._ServiceBag:GetService(require("ToolbarServiceClient"))
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()

    self._UIServiceClient:RegisterUI({
        UIName = "Toolbar",
        Category = "HUD",
        Conflicts = {}
    })
end

function ToolbarUIClient.Start(self: Module)
    self._UIServiceClient:OpenUI("Toolbar")

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        ToolbarComponent({
            IsOpen = self._UIServiceClient:ObserveUI("Toolbar"),
            ObserveSlotItem = function(slotId: ToolbarTypesShared.SlotId)
                return self._ToolbarServiceClient:ObserveSlotItem(slotId)
            end,
            ObserveEquippedSlotId = self._ToolbarServiceClient:ObserveEquippedSlotId(),
            OnSlotPressed = function(slotId: ToolbarTypesShared.SlotId)
                self._ToolbarServiceClient:EquipSlot(slotId)
            end,
        })
    } end))
end

return ToolbarUIClient :: Module
