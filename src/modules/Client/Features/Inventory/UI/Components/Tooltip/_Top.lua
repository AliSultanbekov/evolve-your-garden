
--[=[
    @class Top
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ImageConfig = require("ImageConfig")
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
local Top = function(props: Props)
    local ItemName = Blend.Computed(props.Item, function(item)
        return item.Name
    end)

    local RarityImage = Blend.Computed(props.Item, function(item)
        return ImageConfig.Inventory.RarityImages[ItemConfig:GetRarity(item.Name, item.Category)]
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
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(255, 85);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "TextLabel" {
            Name = "Name";
            Position = UDim2.fromOffset(110, 8);
            Size = UDim2.fromOffset(135, 30);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            Text = ItemName;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 20;
            TextWrapped = true;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(0, 71, 97);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 2;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Rarity";
            Position = UDim2.fromOffset(130, 45);
            Size = UDim2.fromOffset(97, 27);
            BackgroundTransparency = 1;
            Image = RarityImage;
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "Rays";
            Position = UDim2.fromOffset(-21+(142.2/2), -61+(142.2/2));
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.fromOffset(160, 160);
            BackgroundTransparency = 1;
            Image = "rbxassetid://77591497948171";
            ZIndex = 2;
            Rotation = Rotation;
        };
        Blend.New "ImageLabel" {
            Name = "Icon";
            Position = UDim2.fromOffset(-17, -56);
            Size = UDim2.fromOffset(133, 133);
            BackgroundTransparency = 1;
            Image = ItemIcon;
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 3;
        };
    };
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
    AnimateEffects: Observable.Observable<boolean>,
}
type ModuleData = {}

export type Module = typeof(Top) & ModuleData

return Top :: Module