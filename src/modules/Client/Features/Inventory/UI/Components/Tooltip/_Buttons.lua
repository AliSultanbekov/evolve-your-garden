--[=[
    @class Buttons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemTypes = require("ItemTypes")
local Rx = require("Rx")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function PlantButtons(ItemCategory: Observable.Observable<ItemTypes.Category>)
    return {
        GenericButtonComponent({
            Name = "Close";
            Position = UDim2.fromOffset(55, 51);
            Size = UDim2.fromOffset(145, 40);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://90981983108850",
            Visible = Blend.Computed(ItemCategory, function(category: ItemTypes.Category)
                return category == "Plant"
            end),
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(3, 7);
                    Size = UDim2.fromOffset(139, 24);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                    Text = "Encyclopaedia";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 18;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(106, 73, 26);
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
        Visible = props.IsSelected;
        BackgroundTransparency = 1;
        Blend.New "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 5)
        },
        Blend.New "UIPadding" {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        },
        GenericButtonComponent({
            Name = "Close";
            Position = UDim2.fromOffset(55, 51);
            Size = UDim2.fromOffset(145, 40);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            LayoutOrder = 100,
            Image = "rbxassetid://86203887540539",
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(3, 7);
                    Size = UDim2.fromOffset(139, 24);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                    Text = "Close";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 18;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(106, 0, 0);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 2;
                    };
                };
            }
        }),
        PlantButtons(ItemCategory)
    }
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
    IsSelected: Observable.Observable<boolean>,
}
type ModuleData = {}

export type Module = typeof(Buttons) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Buttons :: Module