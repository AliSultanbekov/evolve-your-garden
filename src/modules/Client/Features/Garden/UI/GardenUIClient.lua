--[=[
    @class GardenUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Blend = require("Blend")
local GardenTypesShared = require("GardenTypesShared")
local ReactiveItmeTypes = require("ReactiveItemTypes")

local PlantPickerWindow = require(script.Parent.Components.PlantPickerWindow.PlantPickerWindowComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _GardenServiceClient: typeof(require("GardenServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(GardenUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._GardenServiceClient = self._ServiceBag:GetService(require("GardenServiceClient"))
    self._Maid = Maid.new()
end

function GardenUIClient.Start(self: Module)
    self._UIServiceClient:RegisterUI({
        UIName = "GardenPlantPicker",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        }
    })

    local IsOpen_GardenPlantPicker = self._UIServiceClient:ObserveUI("GardenPlantPicker")
    local Items = self._InventoryServiceClient:GetItems()

    self._Maid:Add(self._GardenServiceClient:ObserveSelectedSlot():Subscribe(function(SlotId: GardenTypesShared.SlotId?)
        if not SlotId then
            self._UIServiceClient:CloseUI("GardenPlantPicker")
        else
            self._UIServiceClient:OpenUI("GardenPlantPicker")
        end
    end))

    self._Maid:Add(Blend.mount(self._UIServiceClient:GetScreen("Main"), {
        PlantPickerWindow({
            IsOpen = IsOpen_GardenPlantPicker,
            Items = Items,
            OnClose = function()
                self._GardenServiceClient:SelectSlot(nil)
            end,
            OnItemPressed = function(item: ReactiveItmeTypes.ReactiveItem)
                self._GardenServiceClient:PlacePlant(item.Id)
            end
        })
    }))
end

return GardenUIClient :: Module