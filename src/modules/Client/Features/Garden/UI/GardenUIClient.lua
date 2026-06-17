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
local ValueObject = require("ValueObject")
local GardenTypesShared = require("GardenTypesShared")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Components ] --
local PlantPickerWindow = require(script.Parent.Components.PlantPickerWindow._Window)

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
    _Search: ValueObject.ValueObject<string>,
    _HoveredItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>
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
    self._Search = ValueObject.new("")
    self._HoveredItem = ValueObject.new(nil)
end

function GardenUIClient.Start(self: Module)
    self._UIServiceClient:RegisterUI({
        UIName = "GardenPlantPicker",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })

    self._UIServiceClient:CloseUI("GardenPlantPicker")

    self._GardenServiceClient:ObserveSelectedSlot():Subscribe(function(slotId: GardenTypesShared.SlotId?)
        if not slotId then
            self._UIServiceClient:CloseUI("GardenPlantPicker")
        else
            self._UIServiceClient:OpenUI("GardenPlantPicker")
        end
    end)

    self._Maid:Add(Blend.mount(self._UIServiceClient:GetScreen("Main"), {
        PlantPickerWindow({
            IsOpen = self._UIServiceClient:ObserveUI("GardenPlantPicker"),
            Search = self._Search:Observe(),

            OnClose = function()
                self._UIServiceClient:CloseUI("GardenPlantPicker")
                self._GardenServiceClient:SelectSlot(nil)
            end,
            GetItems = function()
                return self._InventoryServiceClient:GetItems("Garden")
            end,
            OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem)
                local SelectedSlot = self._GardenServiceClient:GetSelectedSlot()

                if not SelectedSlot then
                    return
                end

                self._GardenServiceClient:PlacePlant(SelectedSlot, item.Id)
            end,
            OnItemHovered = function(item: ReactiveItemTypes.ReactiveItem)
                self._HoveredItem.Value = item
            end,
            OnItemUnhovered = function()
                self._HoveredItem.Value = nil
            end,
            OnSearch = function(search: string)
                self._Search.Value = search
            end
        })
    }))
end

return GardenUIClient :: Module