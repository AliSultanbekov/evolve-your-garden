--[=[
    @class MerchantUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")

-- [ Components ] --
local Merchant = require(script.Parent.Components._Merchant)
local ItemTooltip = require(script.Parent.Components._ItemTooltip)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _MerchantServiceClient: typeof(require("MerchantServiceClient")),
    _MouseServiceClient: typeof(require("MouseServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>,
    _Search: ValueObject.ValueObject<string>,
    _HoveredItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>,
    _SelectedItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>,
    _SelectedItemPosition: ValueObject.ValueObject<UDim2?>,
    _SelectedItemSellAmount: ValueObject.ValueObject<number>
}

export type Module = typeof(MerchantUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantUIClient.SetupItemTooltip(self: Module)
    local DisplayItem = Rx.combineLatest({
        HoveredItem = self._HoveredItem:Observe(),
        SelectedItem = self._SelectedItem:Observe()
    }):Pipe({
        Rx.map(function(data)
            return data.SelectedItem or data.HoveredItem
        end) :: any
    }) :: any

    local IsSelected = self._SelectedItem:Observe():Pipe({
        Rx.map(function(isSelected)
            return isSelected ~= nil
        end) :: any
    }) :: any

    local Position = Rx.combineLatest({
        SelectedPosition = self._SelectedItemPosition:Observe(),
        IsSelected = IsSelected,
        DisplayItem = DisplayItem,
        MousePosition = self._MouseServiceClient:ObserveMousePosition(),
    }):Pipe({
        Rx.where(function(data)
            return data.DisplayItem ~= nil
        end) :: any,
        Rx.map(function(data: any)
            if data.IsSelected and data.SelectedPosition then
                return data.SelectedPosition + UDim2.fromOffset(80, 60)
            else
                return UDim2.fromOffset(data.MousePosition.X + 30, data.MousePosition.Y)
            end
        end) :: any,
        Rx.distinct() :: any
    }) :: any

    self._Maid:Add(self._UIServiceClient:ObserveUI("Merchant"):Subscribe(function(isOpen: boolean)
        if not isOpen then
            self._SelectedItem.Value = nil
            self._SelectedItemPosition.Value = nil 
        end
    end))

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        ItemTooltip({
            Item = DisplayItem,
            IsSelected = IsSelected,
            Position = Position,
            MousePosition = self._MouseServiceClient:ObserveMousePosition(),
            Actions = {
                Sell = function()
                    local SelectedItem = self._SelectedItem.Value :: ReactiveItemTypes.ReactiveStackableItem

                    if not SelectedItem then
                        return
                    end

                    local Amount = self._SelectedItemSellAmount.Value

                    self._MerchantServiceClient:Sell(SelectedItem.Id, Amount)

                    if Amount >= SelectedItem.Amount.Value then
                        self._SelectedItem.Value = nil
                    end

                    self._SelectedItemSellAmount.Value = 1
                end,
            },
            SelectedItemSellAmount = self._SelectedItemSellAmount:Observe(),
            SelectedItemMaxSellAmount = self._SelectedItem:Observe():Pipe({
                Rx.switchMap(function(item: ReactiveItemTypes.ReactiveItem?)
                    if not item then
                        return Rx.of(1) :: any
                    end

                    local Stackable = item :: ReactiveItemTypes.ReactiveStackableItem

                    return Stackable.Amount:Observe()
                end) :: any,
            }) :: any,
            OnClose = function()
                self._SelectedItem.Value = nil
            end,
            IncrementSelectedItemSellAmount = function()
                local SelectedItem = self._SelectedItem.Value :: ReactiveItemTypes.ReactiveStackableItem

                if not SelectedItem then
                    return
                end

                if SelectedItem.Amount.Value <= self._SelectedItemSellAmount.Value then
                    return
                end

                self._SelectedItemSellAmount.Value += 1
            end,
            DecrementSelectedItemSellAmount = function()
                if self._SelectedItemSellAmount.Value <= 1 then
                    return
                end
                
                self._SelectedItemSellAmount.Value -= 1
            end,
            SetSelectedItemSellAmount = function(amount: number)
                local SelectedItem = self._SelectedItem.Value :: ReactiveItemTypes.ReactiveStackableItem

                if not SelectedItem then
                    return
                end

                self._SelectedItemSellAmount.Value = math.clamp(math.floor(amount), 1, SelectedItem.Amount.Value)
            end,
        })
    } end))
end

function MerchantUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._MerchantServiceClient = self._ServiceBag:GetService(require("MerchantServiceClient"))
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Sell")
    self._Search = ValueObject.new("")
    self._HoveredItem = ValueObject.new()
    self._SelectedItem = ValueObject.new()
    self._SelectedItemPosition = ValueObject.new()
    self._SelectedItemSellAmount = ValueObject.new(1)

    self._UIServiceClient:RegisterUI({
        UIName = "Merchant",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        }
    })
end

function MerchantUIClient.Start(self: Module)
    self:SetupItemTooltip()

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        Merchant({
            IsOpen = self._UIServiceClient:ObserveUI("Merchant"),
            ActiveTab = self._ActiveTab:Observe(),
            Items = self._InventoryServiceClient:GetItemsByCategory("Material"),
            Search = self._Search:Observe(),
            BuySlots = self._MerchantServiceClient:GetBuySlots(),
            LastRefresh = self._MerchantServiceClient:ObserveLastRefresh(),

            SwitchTab = function(tab: string)
                self._ActiveTab.Value = tab
            end,
            Buy = function(slotId: string)
                self._MerchantServiceClient:Buy(slotId)
            end,
            Sell = function(itemId: string, amount: number)
                self._MerchantServiceClient:Sell(itemId, amount)
            end,
            OnSearch = function(text: string)
                self._Search.Value = text
            end,
            OnClose = function()
                self._UIServiceClient:CloseUI("Merchant")
            end,
            ItemPressed = function(item: ReactiveItemTypes.ReactiveItem, position: UDim2)
                self._SelectedItem.Value = item
                self._SelectedItemPosition.Value = position
            end,
            ItemHovered = function(item: ReactiveItemTypes.ReactiveItem)
                self._HoveredItem.Value = item
            end,
            ItemUnhovered = function(item: ReactiveItemTypes.ReactiveItem)
                if self._HoveredItem.Value ~= item then
                    return
                end

                self._HoveredItem.Value = nil
            end
        })
    } end))
end

return MerchantUIClient :: Module