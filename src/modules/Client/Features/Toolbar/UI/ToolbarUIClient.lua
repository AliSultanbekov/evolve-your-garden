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
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
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
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
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
            IsInventoryOpen = self._UIServiceClient:ObserveUI("Inventory"),
            InventorySelectedItem = self._InventoryServiceClient:ObserveSelectedItem(),
            ObserveItemFromSlotId = function(slotId: ToolbarTypesShared.SlotId)
                return self._ToolbarServiceClient:ObserveItemFromSlotId(slotId)
            end,
            ObserveEquippedSlotId = self._ToolbarServiceClient:ObserveEquippedSlotId(),
            OnSlotPressed = function(slotId: ToolbarTypesShared.SlotId)
                if self._UIServiceClient:GetUIState("Inventory") then
                    local SelectedItem = self._InventoryServiceClient:GetSelectedItem()

                    if self._ToolbarServiceClient:GetSlot(slotId).Value then
                        if SelectedItem then
                            return
                        end

                        self._ToolbarServiceClient:UnbindSlot(slotId)
                    else
                        if not SelectedItem then
                            return
                        end

                        self._ToolbarServiceClient:BindSlot(slotId, SelectedItem.Id)
                    end
                else
                    self._ToolbarServiceClient:EquipSlot(slotId)
                end
            end,
        })
    } end))


end

return ToolbarUIClient :: Module
