--[=[
    @class InventoryUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")

-- [ Components ] --
local InventoryWindow = require(script.Parent.Components.Inventory._Window)
local TooltipWindow = require(script.Parent.Components.Tooltip._Window)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>,
    _SelectedItemPosition: ValueObject.ValueObject<UDim2?>,
    _HoveredItemPosition: ValueObject.ValueObject<UDim2?>,
    _Search: ValueObject.ValueObject<string>
}

export type Module = typeof(InventoryUIClient) & ModuleData

-- [ Private Functions ] --
function InventoryUIClient._SetupTooltip(self: Module)
    local Item = ValueObject.new(nil) :: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>
    local IsSelected = ValueObject.new(false) :: ValueObject.ValueObject<boolean>
    local Position = ValueObject.new(nil) :: ValueObject.ValueObject<UDim2?>

    self._Maid:Add(Rx.combineLatest({
        SelectedItem = self._InventoryServiceClient:ObserveSelectedItem(),
        SelectedPosition = self._SelectedItemPosition:Observe(),
        HoveredItem = self._InventoryServiceClient:ObserveHoveredItem(),
        HoveredPosition = self._HoveredItemPosition:Observe()
    }):Subscribe(function(data: any)
        if data.SelectedItem then
            IsSelected.Value = true
            Item.Value = data.SelectedItem
            Position.Value = data.SelectedPosition
        else
            IsSelected.Value = false
            Item.Value = data.HoveredItem
            Position.Value = data.HoveredPosition
        end
    end))

    self._Maid:Add(Blend.mount(self._UIServiceClient:GetScreen("Misc"), {
        TooltipWindow({
            Item = Item:Observe(),
            IsSelected = IsSelected:Observe(),
            Position = Position:Observe(),
        })
    }))
end

function InventoryUIClient._SetupInventory(self: Module)
    self._UIServiceClient:RegisterUI({
        UIName = "Inventory",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })

    self._UIServiceClient:CloseUI("Inventory")

    self._Maid:Add(Blend.mount(self._UIServiceClient:GetScreen("Main"), {
        InventoryWindow({
            IsOpen = self._UIServiceClient:ObserveUI("Inventory"),
            ActiveTab = self._ActiveTab:Observe(),
            Search = self._Search:Observe(),
            SwitchTab = function(tabName: string)
                self._ActiveTab.Value = tabName
            end,
            GetItems = function(filter: string?)
                return self._InventoryServiceClient:GetItems(filter)
            end,
            OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem, position: UDim2)
                self._InventoryServiceClient:SelectItem(item)
                self._SelectedItemPosition.Value = position
            end,
            OnItemHovered = function(item: ReactiveItemTypes.ReactiveItem, position: UDim2)
                if not self._InventoryServiceClient:GetSelectedItem() then
                    self._InventoryServiceClient:HoverItem(item)
                    self._HoveredItemPosition.Value = position
                end
            end,
            OnItemUnhovered = function()
                if not self._InventoryServiceClient:GetSelectedItem() then
                    self._InventoryServiceClient:HoverItem()
                end
            end,
            OnClose = function()
                self._UIServiceClient:CloseUI("Inventory")
            end,
            OnSearch = function(text: string)
                print(text)
                self._Search.Value = text
            end
        })
    }))
end

-- [ Public Functions ] --
function InventoryUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Garden")
    self._SelectedItemPosition = ValueObject.new(nil)
    self._HoveredItemPosition = ValueObject.new(nil)
    self._Search = ValueObject.new("")
end

function InventoryUIClient.Start(self: Module)
    self:_SetupInventory()
    self:_SetupTooltip()
end

return InventoryUIClient :: Module