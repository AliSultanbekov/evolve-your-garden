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
        Size = UDim2.fromOffset(118, 48);
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
                        Size = UDim2.fromOffset(110, 37);
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

local function PlantButtons(
    IsSelected: Observable.Observable<boolean>,
    actions: InventoryTypesClient.Actions
)
    return {
        AnimatedButton({
            Name = "Harvest";
            IsOpen = IsSelected;
            Image = "rbxassetid://97250954730348";
            Text = "Harvest";
            StrokeColor = Color3.fromRGB(14, 100, 13);
            OnPressed = function()
                actions.Harvest()
            end;
        }),
        AnimatedButton({
            Name = "Info";
            IsOpen = IsSelected;
            Image = "rbxassetid://138905656018275";
            Text = "Info";
            StrokeColor = Color3.fromRGB(115, 70, 34);
            OnPressed = function()
                actions.Info()
            end;
        }),
        AnimatedButton({
            Name = "DigUp";
            IsOpen = IsSelected;
            Image = "rbxassetid://102732472413370";
            Text = "Dig up";
            StrokeColor = Color3.fromRGB(117, 26, 25);
            OnPressed = function()
                actions.DigUp()
            end;
        }),
    }
end

-- [ Module Table ] --
local Buttons = function(props: Props)
    return Blend.New "Frame" {
        Name = "Buttons";
        LayoutOrder = 2;
        Position = UDim2.fromOffset(0, 265);
        Size = UDim2.fromOffset(255, 0);
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1;
        Blend.New "UIGridLayout" {
            CellSize = UDim2.fromOffset(118, 48);
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        Blend.New "UIPadding" {
            PaddingTop = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 3 else 0)
            end),
            PaddingBottom = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 3    else 0)
            end),
        },
        AnimatedButton({
            Name = "Close";
            LayoutOrder = 100;
            IsOpen = props.IsSelected;
            Image = "rbxassetid://101276568553496";
            Text = "Close";
            StrokeColor = Color3.fromRGB(130, 40, 40);
            OnPressed = props.Actions.Close;
        }),
        PlantButtons(props.IsSelected, props.Actions),
    }
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
    IsSelected: Observable.Observable<boolean>,
    Actions: { [string]: (...any) -> (...any) },
}
type ModuleData = {}

export type Module = typeof(Buttons) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Buttons :: Module
