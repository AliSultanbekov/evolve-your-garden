--[=[
    @class ItemTooltipComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Components ] --
local TooltipShellComponent = require("TooltipShellComponent")
local Buttons = require(script._Buttons)
local AmountSelector = require(script._AmountSelector)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local ItemTooltipComponent = function(props: Props)
    return TooltipShellComponent({
        Item = props.Item,
        Position = props.Position,
        AnchorPoint = Vector2.new(0, 0.5),
        PaddingBottom = 3,
        Content = function(displayItem, _isOpen)
            return { 
                Buttons({
                    Item = displayItem,
                    IsSelected = props.IsSelected,

                    Actions = props.Actions,

                    OnClose = props.OnClose,
                });
                AmountSelector({
                    IsSelected = props.IsSelected,
                    SelectedItemSellAmount = props.SelectedItemSellAmount,
                    SelectedItemMaxSellAmount = props.SelectedItemMaxSellAmount,
                    MousePosition = props.MousePosition,

                    IncrementSelectedItemSellAmount = props.IncrementSelectedItemSellAmount;
                    DecrementSelectedItemSellAmount = props.DecrementSelectedItemSellAmount;
                    SetSelectedItemSellAmount = props.SetSelectedItemSellAmount;
                });
            }
        end,
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    IsSelected: Observable.Observable<boolean>,
    Position: Observable.Observable<UDim2>,
    Actions: InventoryTypesClient.Actions,
    SelectedItemSellAmount: Observable.Observable<number>,
    SelectedItemMaxSellAmount: Observable.Observable<number>,
    MousePosition: Observable.Observable<Vector2>,

    OnClose: () -> (),
    IncrementSelectedItemSellAmount: () -> ();
    DecrementSelectedItemSellAmount: () -> ();
    SetSelectedItemSellAmount: (amount: number) -> ();
}

type ModuleData = {}

export type Module = typeof(ItemTooltipComponent) & ModuleData

return ItemTooltipComponent :: Module
