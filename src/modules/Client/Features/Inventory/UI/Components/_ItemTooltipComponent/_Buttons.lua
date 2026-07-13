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
local GenericButtonComponent = require("GenericButtonComponent")
local AnimatedFrameComponent = require("AnimatedFrameComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function AnimatedButton(props: {
    Name: string,
    LayoutOrder: number?,
    IsOpen: Observable.Observable<boolean>,
    Image: string,
    Text: string,
    StrokeColor: Color3,
    OnPressed: (...any) -> ...any,
})
    return AnimatedFrameComponent({
        Name = props.Name;
        IsOpen = props.IsOpen;
        Size = UDim2.fromOffset(179, 48);
        LayoutOrder = props.LayoutOrder;
        BackgroundTransparency = 1;
        Children = {
            GenericButtonComponent({
                Name = props.Name;
                Size = UDim2.fromScale(1, 1);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                Image = props.Image;
                OnPressed = props.OnPressed;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Name";
                        Position = UDim2.fromOffset(4, 4);
                        Size = UDim2.fromOffset(171, 37);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = props.Text;
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 18;
                        ZIndex = 2;
                        Blend.New "UIStroke" {
                            Color = props.StrokeColor;
                            LineJoinMode = Enum.LineJoinMode.Miter;
                            Thickness = 2;
                        };
                    };
                };
            });
        };
    })
end

-- Intentionally empty for now: there is no plant action usable from the
-- inventory yet (planting goes through the garden slot picker, not here).
-- Add buttons once a plant UseAction exists server-side.
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
        AnimatedButton({
            Name = "Open 3";
            IsOpen = ShouldShow;
            Image = "rbxassetid://97250954730348";
            Text = "Open 3";
            StrokeColor = Color3.fromRGB(14, 100, 13);
            OnPressed = function()
                actions.Open(3)
            end;
        }),
        AnimatedButton({
            Name = "Open 1";
            IsOpen = ShouldShow;
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
        AnimatedButton({
            Name = "Close";
            LayoutOrder = 100;
            IsOpen = props.IsSelected;
            Image = "rbxassetid://101276568553496";
            Text = "Close";
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
