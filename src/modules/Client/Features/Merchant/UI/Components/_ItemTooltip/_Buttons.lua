--[=[
    @class Buttons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemTypes = require("ItemTypes")
local Rx = require("Rx")
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Components ] --
local AnimatedButtonComponent = require("AnimatedButtonComponent")

-- [ Constants ] --
local BUTTON_SIZE = UDim2.fromOffset(179, 48)

-- [ Variables ] --

-- [ Functions ] --

local function PlantButtons(
    isSelected: Observable.Observable<boolean>,
    itemCategory: Observable.Observable<ItemTypes.Category>,
    actions: InventoryTypesClient.Actions
)
    return {

    }
end

local function PackButtons(
    isSelected: Observable.Observable<boolean>,
    itemCategory: Observable.Observable<ItemTypes.Category>,
    actions: InventoryTypesClient.Actions
)
    local ShouldShow = Blend.Computed(isSelected, itemCategory, function(selected: boolean, category: ItemTypes.Category)
        return selected and category == "Pack"
    end)

    return {
        AnimatedButtonComponent({
            Name = "Open 3";
            IsOpen = ShouldShow;
            Size = BUTTON_SIZE;
            Image = "rbxassetid://97250954730348";
            Text = "Open 3";
            StrokeColor = Color3.fromRGB(14, 100, 13);
            OnPressed = function()
                actions.Open(3)
            end;
        }),
        AnimatedButtonComponent({
            Name = "Open 1";
            IsOpen = ShouldShow;
            Size = BUTTON_SIZE;
            Image = "rbxassetid://97250954730348";
            Text = "Open 1";
            StrokeColor = Color3.fromRGB(14, 100, 13);
            OnPressed = function()
                actions.Open(1)
            end;
        }),
    }
end

-- [ Module Table ] --
local Buttons = function(props: Props)
    local ItemCategory = (props.Item :: any):Pipe({
        Rx.map(function(item: ReactiveItemTypes.ReactiveItem)
            return item.Category
        end)
    })

    return Blend.New "Frame" {
        Name = "Buttons";
        LayoutOrder = 2;
        Position = UDim2.fromOffset(0, 265);
        Size = UDim2.fromOffset(255, 0);
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1;
        Blend.New "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 5)
        },
        Blend.New "UIPadding" {
            PaddingTop = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 10 else 0)
            end),
            PaddingBottom = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 10 else 0)
            end),
        },
        AnimatedButtonComponent({
            Name = "Sell";
            LayoutOrder = 1;
            IsOpen = props.IsSelected;
            Size = BUTTON_SIZE;
            Image = "rbxassetid://138166573995722";
            Text = "Sell";
            TextSize = 22;
            StrokeColor = Color3.fromRGB(0, 105, 3);
            OnPressed = function()
                props.Actions.Sell()
            end;
        }),
        AnimatedButtonComponent({
            Name = "Close";
            LayoutOrder = 100;
            IsOpen = props.IsSelected;
            Size = BUTTON_SIZE;
            Image = "rbxassetid://98430497084904";
            Text = "Close";
            TextSize = 22;
            StrokeColor = Color3.fromRGB(130, 40, 40);
            OnPressed = props.OnClose;
        }),
        PlantButtons(props.IsSelected, ItemCategory, props.Actions),
        PackButtons(props.IsSelected, ItemCategory, props.Actions)
    }
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
    IsSelected: Observable.Observable<boolean>,
    Actions: InventoryTypesClient.Actions,

    OnClose: () -> (),
}
type ModuleData = {}

export type Module = typeof(Buttons) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Buttons :: Module
