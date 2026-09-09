--[=[
    @class PackCard
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local PackStoreTypesClient = require("PackStoreTypesClient")
local Observable = require("Observable")
local PackStoreConfig = require("PackStoreConfig")
local NumberLocalizationUtils = require("NumberLocalizationUtils")
local RoundingBehaviourTypes = require("RoundingBehaviourTypes")
local PackStoreTypesShared = require("PackStoreTypesShared")
local Rx = require("Rx")

-- [ Components ] --
local AnimatedButtonComponent = require("AnimatedButtonComponent")

-- [ Constants ] --

-- [ Variables ] --
local RenderStepped = Rx.fromSignal(RunService.RenderStepped):Pipe({
    Rx.share() :: any
})

-- [ Functions ] --

-- [ Module Table ] --
local PackCard = function(props: Props)
    local Pack = props.Pack
    local PackPrice = PackStoreConfig.Prices[Pack.Category][Pack.Name].Amount

    local Rotation = (props.AnimateEffects :: any):Pipe({
        Rx.switchMap(function(shouldAnimate: boolean)
            if not shouldAnimate then
                return Rx.of(0) :: any
            end

            return (RenderStepped :: any):Pipe({
                Rx.scan(function(acc, dt: number) return (acc or 0) + dt * 45 end, 0),
                Rx.map(function(r: number) return r % 360 end)
            })
        end)
    })

    return Blend.New "Frame" {
        Name = "PackCard";
        Size = UDim2.fromOffset(318, 453);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://122360671213114";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "Rays";
            Position = UDim2.fromOffset(-8 + 334 / 2, 68 + 333 / 2);
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.fromOffset(334, 333);
            BackgroundTransparency = 1;
            Image = "rbxassetid://97489278730613";
            ZIndex = 2;
            Rotation = Rotation;
        };
        Blend.New "ImageLabel" {
            Name = "Pack";
            Position = UDim2.fromOffset(3, 91);
            Size = UDim2.fromOffset(312, 288);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://128387498316353";
            ZIndex = 3;
        };
        AnimatedButtonComponent({
            Name = "Buy";
            Position = UDim2.fromOffset(162 + 146 / 2, 387 + 56 / 2);
            Size = UDim2.fromOffset(146, 56);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://90926194777589";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 4;
            OnPressed = function()
                props.BuyPack(Pack.Id)
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Title";
                    Position = UDim2.fromOffset(6, 6);
                    Size = UDim2.fromOffset(134, 41);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Buy";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 29;
                    TextWrapped = true;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(21, 96, 20);
                        Thickness = 3;
                    };
                };
            }
        });
        Blend.New "Frame" {
            Name = "Price";
            Position = UDim2.fromOffset(10, 387);
            Size = UDim2.fromOffset(146, 56);
            BackgroundTransparency = 1;
            ZIndex = 5;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://131494745355914";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "TextLabel" {
                Name = "Amount";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(54, 3);
                Size = UDim2.fromOffset(89, 50);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = NumberLocalizationUtils.abbreviate(PackPrice, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 38;
                TextWrapped = true;
                ZIndex = 2;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 3;
                };
            };
            Blend.New "ImageLabel" {
                Name = "Icon";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(3, 3);
                Size = UDim2.fromOffset(50, 50);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://113750740810118";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 3;
            };
        };
        Blend.New "ImageLabel" {
            Name = "PoolInfo";
            Position = UDim2.fromOffset(12, 99);
            Size = UDim2.fromOffset(46, 46);
            BackgroundTransparency = 1;
            Image = "rbxassetid://77147524403860";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 6;
        };
        Blend.New "TextLabel" {
            Name = "Name";
            Position = UDim2.fromOffset(6, 6);
            Size = UDim2.fromOffset(306, 75);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = Pack.Name;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 29;
            TextWrapped = true;
            ZIndex = 7;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "TextLabel" {
            Name = "Stock";
            Position = UDim2.fromOffset(221, 331);
            Size = UDim2.fromOffset(61, 29);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = Blend.Computed(Pack.Left, function(left: number)
                return tostring(left) .. "/" .. tostring(Pack.Stock)
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 29;
            TextWrapped = true;
            ZIndex = 8;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
    }
end

-- [ Types ] --
type Props = {
    Pack: PackStoreTypesClient.ReactivePack,
    AnimateEffects: Observable.Observable<boolean>,
    BuyPack: (packId: PackStoreTypesShared.PackId) -> (),
}
type ModuleData = {}

export type Module = typeof(PackCard) & ModuleData

return PackCard :: Module
