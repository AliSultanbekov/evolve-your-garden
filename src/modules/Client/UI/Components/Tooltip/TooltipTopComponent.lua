--[=[
    @class TooltipTopComponent

    Shared tooltip header: spinning rays, item icon, rarity badge and name.
    Used by every item/plant tooltip (inventory item, garden item, world plant).
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ComponentTypes = require("ComponentTypes")
local ImagesConfig = require("ImagesConfig")
local ItemConfig = require("ItemConfig")
local Rx = require("Rx")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --
local RenderStepped = Rx.fromSignal(RunService.RenderStepped):Pipe({
    Rx.share() :: any
})

-- [ Functions ] --

-- [ Module Table ] --
local TooltipTopComponent = function(props: Props)
    local ItemName = Blend.Computed(props.Item, function(item)
        return item.Name
    end)

    local RarityImage = Blend.Computed(props.Item, function(item)
        return ImagesConfig.Inventory.RarityImages[ItemConfig:GetRarity(item.Name, item.Category)]
    end)

    local ItemIcon = Blend.Computed(props.Item, function(item)
        return ItemConfig:GetIcon(item.Name, item.Category)
    end)

    local Rotation = (props.AnimateEffects :: any):Pipe({
        Rx.switchMap(function(shouldAnimate: boolean)
            if not shouldAnimate then
                return Rx.of(0) :: any
            end

            return (RenderStepped :: any):Pipe({
                Rx.scan(function(acc, dt: number) return (acc or 0) + dt * 45 end, 0),
                Rx.map(function(r: number) return r % 360 end),
            })
        end) :: any,
    })

    return Blend.New "Frame" {
        Name = "Top";
        LayoutOrder = 0;
        Size = UDim2.new(1, 0, 0, 81);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Rays";
            Position = UDim2.fromOffset(-28 + 142 / 2, -71 + 142 / 2);
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.fromOffset(142, 142);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://77591497948171";
            ZIndex = 1;
            Rotation = Rotation;
        };
        Blend.New "ImageLabel" {
            Name = "Rarity";
            Position = UDim2.fromOffset(106, 37);
            Size = UDim2.fromOffset(84, 24);
            BackgroundTransparency = 1;
            Image = RarityImage;
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "Icon";
            Position = UDim2.fromOffset(-24, -66);
            Size = UDim2.fromOffset(133, 133);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = ItemIcon;
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
        Blend.New "TextLabel" {
            Name = "Name";
            Position = UDim2.fromOffset(109, 15);
            Size = UDim2.fromOffset(127, 15);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = ItemName;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextScaled = true;
            TextSize = 16;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 3;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(32, 83, 118);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 2;
            };
        };
    };
end

-- [ Types ] --
type Props = {
    Item: ComponentTypes.Prop<ReactiveItemTypes.ReactiveItem>,
    AnimateEffects: Observable.Observable<boolean>,
}
type ModuleData = {}

export type Module = typeof(TooltipTopComponent) & ModuleData

return TooltipTopComponent :: Module
