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

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function PlantButtons(IsSelected: Observable.Observable<boolean>, ItemCategory: Observable.Observable<ItemTypes.Category>, actions: InventoryTypesClient.Actions)
    return {

    }
end

local function PackButtons(IsSelected: Observable.Observable<boolean>, ItemCategory: Observable.Observable<ItemTypes.Category>, actions: InventoryTypesClient.Actions)
    local ShouldShow = Blend.Computed(IsSelected, ItemCategory, function(selected: boolean, category: ItemTypes.Category)
        return selected and category == "Pack"
    end)

    return {
        GenericButtonComponent({
            Name = "Open 3";
            Position = UDim2.fromOffset(55, 51);
            Size = UDim2.fromOffset(179, 48);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://97250954730348",
            Visible = ShouldShow,
            AnimateVisibility = true,
            OnPressed = function()
                actions.Open(3)
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(171, 37);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Open 3";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 18;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(14, 100, 13);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 2;
                    };
                };
            }
        });
        GenericButtonComponent({
            Name = "Open 1";
            Position = UDim2.fromOffset(55, 51);
            Size = UDim2.fromOffset(179, 48);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://97250954730348",
            Visible = ShouldShow,
            AnimateVisibility = true,
            OnPressed = function()
                actions.Open(1)
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(171, 37);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Open 1";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 18;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(14, 100, 13);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 2;
                    };
                };
            }
        });
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
        GenericButtonComponent({
            Name = "Close";
            Position = UDim2.fromOffset(55, 51);
            Size = UDim2.fromOffset(179, 48);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            LayoutOrder = 100;
            Visible = props.IsSelected;
            Image = "rbxassetid://101276568553496";
            OnPressed = props.OnClose;
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(171, 37);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Close";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 18;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(130, 40, 40);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 2;
                    };
                };
            }
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