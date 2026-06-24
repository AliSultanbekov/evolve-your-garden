
--[=[
    @class GardenUIClient
]=]

-- [ Roblox Services ] --
local GuiService = game:GetService("GuiService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local GardenTypesClient = require("GardenTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")

-- [ Components ] --
local PlantPicker = require(script.Parent.Components._PlantPickerComponent)
local PlantTooltip = require(script.Parent.Components._PlantTooltipComponent)
local HighlightComponent = require("HighlightComponent")

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
    _MouseServiceClient: typeof(require("MouseServiceClient")),
    _Maid: Maid.Maid,
    _Search: ValueObject.ValueObject<string>,
    _HoveredItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>
}

export type Module = typeof(GardenUIClient) & ModuleData

-- [ Private Functions ] --
function GardenUIClient._SetupHighlight(self: Module)
    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        HighlightComponent({
            Enabled = Rx.combineLatest({
                SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
                HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
            }):Pipe({
                Rx.map(function(data)
                    if not data.SelectedSlotInfo and not data.HoveredSlotInfo then
                        return false
                    else
                        return true
                    end
                end) :: any
            }),
            OutlineColor = Color3.new(1, 1, 1),
            FillColor = Color3.new(1, 1, 1),
            OutlineTransparency = 0.4,
            FillTransparency = 0.4,
            Adornee = Rx.combineLatest({
                SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
                HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
            }):Pipe({
                Rx.map(function(data)
                    local SlotInfo = data.SelectedSlotInfo or data.HoveredSlotInfo
                    
                    if not SlotInfo then
                        return
                    end

                    local SlotModel = self._GardenServiceClient:GetSlotModel(SlotInfo.GardenId, SlotInfo.SlotId)

                    return SlotModel
                end) :: any
            })
        }),
    } end))
end

function GardenUIClient._SetupTooltip(self: Module)
    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        PlantTooltip({
                Item = Rx.combineLatest({
                    HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
                    SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
                    MainOpen = self._UIServiceClient:ObserveCategory("Main"),
                }):Pipe({
                    Rx.map(function(data)
                        if data.MainOpen then
                            return
                        end

                        local SlotInfo: GardenTypesClient.SlotInfo = nil

                        if not data.HoveredSlotInfo and not data.SelectedSlotInfo then
                            return
                        else
                            SlotInfo = data.HoveredSlotInfo or data.SelectedSlotInfo
                        end

                        local Slot = self._GardenServiceClient:GetSlot(SlotInfo.GardenId, SlotInfo.SlotId)

                        if not Slot then
                            return
                        end

                        return Slot.Plant.Value
                    end) :: any
                }) :: any,
                Position = Rx.combineLatest({
                    HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
                    SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
                    MousePosition = self._MouseServiceClient:ObserveMousePosition(),
                }):Pipe({
                    Rx.where(function(data)
                        return data.HoveredSlotInfo ~= nil and data.SelectedSlotInfo == nil
                    end) :: any,
                    Rx.map(function(data: any)
                        local Position = data.MousePosition - GuiService:GetGuiInset()
                        
                        return UDim2.fromOffset(Position.X + 30, Position.Y)
                    end) :: any
                }) :: any
            })
    } end))
end

function GardenUIClient._SetupPlantPicker(self: Module)
    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        PlantPicker({
            IsOpen = self._GardenServiceClient:ObserveSelectedSlotInfo():Pipe({
                Rx.map(function(selectedSlotInfo)
                    if not selectedSlotInfo then
                        return false
                    end
                    
                    local Slot: GardenTypesClient.ReactiveSlot? = self._GardenServiceClient:GetSlot(selectedSlotInfo.GardenId, selectedSlotInfo.SlotId)

                    if not Slot then
                        return false
                    end

                    if Slot.Plant.Value then
                        return false
                    end

                    return true
                end) :: any,
                Rx.distinct() :: any
            }) :: any,
            Search = self._Search:Observe(),

            OnClose = function()
                self._UIServiceClient:CloseUI("GardenPlantPicker")
            end,
            GetItems = function()
                return self._InventoryServiceClient:GetItems("Garden")
            end,
            OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem)
                local SelectedSlotInfo = self._GardenServiceClient:GetSelectedSlotInfo()

                if not SelectedSlotInfo then
                    return
                end

                self._GardenServiceClient:PlacePlant(SelectedSlotInfo.SlotId, item.Id)
            end,
            OnItemHovered = function(item: ReactiveItemTypes.ReactiveItem)
                self._HoveredItem.Value = item
            end,
            OnItemUnhovered = function(item: ReactiveItemTypes.ReactiveItem)
                if self._HoveredItem.Value ~= item then
                    return
                end

                self._HoveredItem.Value = nil
            end,
            OnSearch = function(text: string)
                self._Search.Value = text
            end
        })
    } end))
end

-- [ Public Functions ] --
function GardenUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._GardenServiceClient = self._ServiceBag:GetService(require("GardenServiceClient"))
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._Maid = Maid.new()
    self._Search = ValueObject.new("")
    self._HoveredItem = ValueObject.new(nil)

    self._UIServiceClient:RegisterUI({
        UIName = "GardenPlantPicker",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })
end

function GardenUIClient.Start(self: Module)
    self._UIServiceClient:CloseUI("GardenPlantPicker")

    self:_SetupHighlight()
    self:_SetupTooltip()
    self:_SetupPlantPicker()

    self._Maid:Add(self._GardenServiceClient:ObserveSelectedSlotInfo():Subscribe(function(slotInfo: GardenTypesClient.SlotInfo?)
        if not slotInfo then
            self._UIServiceClient:CloseUI("GardenPlantPicker")
        else
            self._UIServiceClient:OpenUI("GardenPlantPicker")
        end
    end))

    self._Maid:Add(self._UIServiceClient:ObserveUI("GardenPlantPicker"):Subscribe(function(isOpen: boolean)
        if isOpen then
            return
        else
            self._GardenServiceClient:SelectSlotInfo(nil)
        end
    end))
end

return GardenUIClient :: Module