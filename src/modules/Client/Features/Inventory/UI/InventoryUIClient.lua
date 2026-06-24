--[=[
    @class InventoryUIClient
]=]

-- [ Roblox Services ] --
local GuiService = game:GetService("GuiService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")
local InventoryEnums = require("InventoryEnums")

-- [ Components ] --
local InventoryComponent = require(script.Parent.Components._InventoryComponent)
local ItemTooltipComponent = require(script.Parent.Components._ItemTooltipComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _MouseServiceClient: typeof(require("MouseServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>,
    _SelectedItemPosition: ValueObject.ValueObject<UDim2?>,
    _HoveredItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>,
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
        HoveredItem = self._HoveredItem:Observe(),
        MousePosition = self._MouseServiceClient:ObserveMousePosition(),
    }):Subscribe(function(data: any)
        if data.SelectedItem then

            IsSelected.Value = true
            Item.Value = data.SelectedItem
            Position.Value = data.SelectedPosition
        elseif data.HoveredItem and data.MousePosition then
            IsSelected.Value = false
            Item.Value = data.HoveredItem

            local MousePosition = data.MousePosition - GuiService:GetGuiInset()
            Position.Value = UDim2.fromOffset(MousePosition.X + 30, MousePosition.Y)
        else
            IsSelected.Value = false
            Item.Value = nil
            Position.Value = nil
        end
    end))

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        ItemTooltipComponent({
            Item = Item:Observe(),
            IsSelected = IsSelected:Observe(),
            Position = Position:Observe():Pipe({
                Rx.where(function(position: UDim2?)
                    return position ~= nil
                end) :: any
            }) :: any,
            
            Actions = {
                Open = function(amount: number)
                    self._InventoryServiceClient:UseAction(InventoryEnums.Actions.Open, {
                        Amount = amount
                    })
                end
            },

            OnClose = function()
                self._InventoryServiceClient:SelectItem(nil)
            end,
        })
    } end))
end

function InventoryUIClient._SetupInventory(self: Module)
    self._UIServiceClient:CloseUI("Inventory")
    
    self._Maid:Add(self._UIServiceClient:ObserveUI("Inventory"):Subscribe(function(open: boolean)
        if open == false then
            self._HoveredItem.Value = nil
            self._InventoryServiceClient:SelectItem(nil)
        end
    end))

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        InventoryComponent({
            IsOpen = self._UIServiceClient:ObserveUI("Inventory"),
            ActiveTab = self._ActiveTab:Observe(),
            Search = self._Search:Observe(),

            SwitchTab = function(tabName: string)
                self._ActiveTab.Value = tabName
                self._HoveredItem.Value = nil
                self._InventoryServiceClient:SelectItem(nil)
            end,
            GetItems = function(filter: string?)
                return self._InventoryServiceClient:GetItems(filter)
            end,
            OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem, position: UDim2)
                self._InventoryServiceClient:SelectItem(item)
                self._SelectedItemPosition.Value = position
            end,
            OnItemHovered = function(item: ReactiveItemTypes.ReactiveItem)
                if not self._InventoryServiceClient:GetSelectedItem() then
                    self._HoveredItem.Value = item
                end
            end,
            OnItemUnhovered = function()
                self._HoveredItem.Value = nil
            end,
            OnClose = function()
                self._UIServiceClient:CloseUI("Inventory")
            end,
            OnSearch = function(text: string)
                self._Search.Value = text
            end,
            OnDeleteMode = function()
                
            end
        })
    } end))
end

-- [ Public Functions ] --
function InventoryUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Garden")
    self._SelectedItemPosition = ValueObject.new(nil)
    self._HoveredItem = ValueObject.new(nil)
    self._Search = ValueObject.new("")

    self._UIServiceClient:RegisterUI({
        UIName = "Inventory",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })
end

function InventoryUIClient.Start(self: Module)
    self:_SetupInventory()
    self:_SetupTooltip()
end

return InventoryUIClient :: Module