
--[=[
    @class GardenUIClient
]=]

-- [ Roblox Services ] --
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local GardenTypesClient = require("GardenTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")
local RxCharacterUtils = require("RxCharacterUtils")
local RangeUtil = require("RangeUtil")
local GardenConfigClient = require("GardenConfigClient")

-- [ Components ] --
local HighlightComponent = require("HighlightComponent")
local PlantPicker = require(script.Parent.Components._PlantPickerComponent)
local PlantTooltip = require(script.Parent.Components._PlantTooltipComponent)
local ItemTooltipComponent = require(script.Parent.Components._ItemTooltipComponent)
local PlantHarvestComponent = require(script.Parent.Components._PlantHarvestComponent)

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
function GardenUIClient._SetupPlantHarvest(self: Module)
    self._Maid:Add(Rx.combineLatest({
        IsUIOpen = self._UIServiceClient:ObserveUI("GardenPlantHarvest"),
        SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
    }):Pipe({
        Rx.where(function(data)
            if not data.IsUIOpen then
                return false
            end

            if data.SelectedSlotInfo then
                return false
            end

            return true
        end) :: any
    }):Subscribe(function()
        self._UIServiceClient:CloseUI("GardenPlantHarvest")
    end))

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        PlantHarvestComponent({
            IsOpen = self._UIServiceClient:ObserveUI("GardenPlantHarvest"),
            Garden = self._GardenServiceClient:ObserveLocalGarden(),
            Slot = self._GardenServiceClient:ObserveSelectedSlot(),

            OnClose = function()
                self._GardenServiceClient:SelectSlotInfo(nil)
                self._UIServiceClient:CloseUI("GardenPlantHarvest")
            end,
            OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem)
                
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
            CollectHarvest = function()
                local SelectedSlotInfo = self._GardenServiceClient:GetSelectedSlotInfo()
                
                if not SelectedSlotInfo then
                    return
                end

                local SlotId = SelectedSlotInfo.SlotId

                self._GardenServiceClient:CollectHarvest(SlotId)
            end
        })
    } end))
end

function GardenUIClient._SetupHighlight(self: Module)
    local Enabled = Rx.combineLatest({
        SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
        HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
    }):Pipe({
        Rx.map(function(data)
            return data.SelectedSlotInfo ~= nil or data.HoveredSlotInfo ~= nil
        end) :: any
    })

    local Adornee = Rx.combineLatest({
        SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
        HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
    }):Pipe({
        Rx.map(function(data)
            local SlotInfo = data.SelectedSlotInfo or data.HoveredSlotInfo

            if not SlotInfo then
                return
            end

            return self._GardenServiceClient:GetSlotModel(SlotInfo.GardenId, SlotInfo.SlotId)
        end) :: any
    })

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        HighlightComponent({
            Enabled = Enabled,
            Adornee = Adornee,
            OutlineColor = Color3.new(1, 1, 1),
            FillColor = Color3.new(1, 1, 1),
            OutlineTransparency = 0.4,
            FillTransparency = 0.4,
        }),
    } end))
end

function GardenUIClient._SetupTooltip(self: Module)
    local DisplayItem = Rx.combineLatest({
        HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
        SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
        MainOpen = self._UIServiceClient:ObserveCategory("Main"),
    }):Pipe({
        Rx.switchMap(function(data)
            if data.MainOpen then
                return Rx.of(nil) :: any
            end

            local SlotInfo = data.SelectedSlotInfo or data.HoveredSlotInfo

            if not SlotInfo then
                return Rx.of(nil) :: any
            end

            local Slot = self._GardenServiceClient:GetSlot(SlotInfo.GardenId, SlotInfo.SlotId)

            if not Slot then
                return Rx.of(nil) :: any
            end

            return Slot.Plant:Observe()
        end) :: any,
        Rx.distinct() :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local Position = Rx.combineLatest({
        DisplayItem = DisplayItem,
        HoveredSlotInfo = self._GardenServiceClient:ObserveHoveredSlotInfo(),
        SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
    }):Pipe({
        Rx.switchMap(function(data)
            if not data.DisplayItem then
                return Rx.of(nil) :: any
            end

            if data.SelectedSlotInfo then
                return Rx.fromSignal(RunService.RenderStepped):Pipe({
                    Rx.map(function()
                        local SlotModel = self._GardenServiceClient:GetSlotModel(data.SelectedSlotInfo.GardenId, data.SelectedSlotInfo.SlotId)

                        if not SlotModel then
                            return nil
                        end

                        local WorldPoint = SlotModel:GetPivot():PointToWorldSpace(Vector3.new(0, 5, 0))
                        local ScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(WorldPoint)

                        return UDim2.fromOffset(ScreenPoint.X + 30, ScreenPoint.Y) :: any
                    end) :: any,
                }) :: any
            end

            if data.HoveredSlotInfo then
                return self._MouseServiceClient:ObserveMousePosition():Pipe({
                    Rx.map(function(mouse: Vector2)
                        local Offset = mouse - GuiService:GetGuiInset()

                        return UDim2.fromOffset(Offset.X + 30, Offset.Y)
                    end) :: any,
                }) :: any
            end

            return Rx.of(nil)
        end) :: any,
        Rx.where(function(position)
            return position ~= nil
        end) :: any,
        Rx.distinct() :: any,
    }) :: any

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        PlantTooltip({
                Item = DisplayItem,
                Position = Position,
                IsSelected = self._GardenServiceClient:ObserveSelectedSlotInfo():Pipe({
                    Rx.map(function(slotInfo: GardenTypesClient.SlotInfo?)
                        return slotInfo ~= nil
                    end) :: any
                }) :: any,
                Actions = {
                    ["Close"] = function()
                        self._GardenServiceClient:SelectSlotInfo(nil)
                    end,
                    ["DigUp"] = function()
                        local SelectedSlotId = self._GardenServiceClient:GetSelectedSlotInfo()

                        if not SelectedSlotId then
                            return
                        end

                        self._GardenServiceClient:RemovePlant(SelectedSlotId.SlotId)
                        self._GardenServiceClient:SelectSlotInfo(nil)
                    end,
                    ["Harvest"] = function()
                        self._UIServiceClient:OpenUI("GardenPlantHarvest")
                    end
                }
            })
    } end))
end

function GardenUIClient._SetupPlantPickerTooltip(self: Module)
    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        ItemTooltipComponent({
            Item = self._HoveredItem:Observe(),
            Position = self._MouseServiceClient:ObserveMousePosition():Pipe({
                Rx.map(function(position: Vector2)
                    return UDim2.fromOffset(position.X, position.Y) + UDim2.fromOffset(30, 0)
                end) :: any
            }) :: any,
        })
    } end))
end

function GardenUIClient._SetupPlantPicker(self: Module)
    self._Maid:Add(self._UIServiceClient:ObserveUI("GardenPlantPicker"):Subscribe(function(isOpen: boolean)
        if isOpen then
            return
        else
            self._HoveredItem.Value = nil
            self._GardenServiceClient:SelectSlotInfo(nil)
        end
    end))

    self._Maid:Add(self._GardenServiceClient:ObserveSelectedSlotInfo():Subscribe(function(slotInfo: GardenTypesClient.SlotInfo?)
        if not slotInfo then
            if not self._UIServiceClient:GetUIState("GardenPlantPicker") then
                return
            end

            self._UIServiceClient:CloseUI("GardenPlantPicker")
        else
            local Slot = self._GardenServiceClient:GetSlot(slotInfo.GardenId, slotInfo.SlotId)

            if not Slot then
                return
            end

            if Slot.Plant.Value then
                return
            end

            self._UIServiceClient:OpenUI("GardenPlantPicker")
        end
    end))

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        PlantPicker({
            IsOpen = self._UIServiceClient:ObserveUI("GardenPlantPicker"),
            Search = self._Search:Observe(),

            OnClose = function()
                self._UIServiceClient:CloseUI("GardenPlantPicker")
            end,
            GetItems = function()
                return self._InventoryServiceClient:GetItemsByTab("Garden")
            end,
            OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem)
                local SelectedSlotInfo = self._GardenServiceClient:GetSelectedSlotInfo()

                if not SelectedSlotInfo then
                    return
                end

                self._GardenServiceClient:PlacePlant(SelectedSlotInfo.SlotId, item.Id)
                self._UIServiceClient:CloseUI("GardenPlantPicker")
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

    self._UIServiceClient:RegisterUI({
        UIName = "GardenPlantHarvest",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })
end

function GardenUIClient.Start(self: Module)
    self:_SetupHighlight()
    self:_SetupTooltip()
    self:_SetupPlantPicker()
    self:_SetupPlantPickerTooltip()
    self:_SetupPlantHarvest()

    Rx.combineLatest({
        SelectedSlotInfo = self._GardenServiceClient:ObserveSelectedSlotInfo(),
        Character = RxCharacterUtils.observeLocalPlayerCharacter(),
        _Tick = Rx.fromSignal(RunService.RenderStepped)
    }):Subscribe(function(Data: any)
        if not Data.SelectedSlotInfo then
            return
        end

        if not Data.Character then
            return
        end

        local SlotModel = self._GardenServiceClient:GetSlotModel(Data.SelectedSlotInfo.GardenId, Data.SelectedSlotInfo.SlotId)

        if not SlotModel then
            return
        end

        if RangeUtil:CheckModelRange(Data.Character, SlotModel, GardenConfigClient.InteractionRange) then
            return
        end

        self._GardenServiceClient:SelectSlotInfo(nil)
    end)
end

return GardenUIClient :: Module