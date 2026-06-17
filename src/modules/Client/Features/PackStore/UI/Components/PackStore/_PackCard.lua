--[=[
    @class PackCard
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

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
local GenericButtonComponent = require("GenericButtonComponent")

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
        Blend.New "Frame" {
            Name = "Background";
            Position = UDim2.fromOffset(3, 3);
            Size = UDim2.fromOffset(312, 447);
            BackgroundTransparency = 1;
            Blend.New "ImageLabel" {
                Name = "Background";
                Position = UDim2.fromOffset(-3, -3);
                Size = UDim2.fromOffset(318, 453);
                BackgroundTransparency = 1;
                Image = "rbxassetid://132194598816904";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "ImageLabel" {
                Name = "Header";
                Position = UDim2.fromOffset(-3, -3);
                Size = UDim2.fromOffset(318, 71);
                BackgroundTransparency = 1;
                Image = "rbxassetid://128769191941711";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
        };
        Blend.New "TextLabel" {
            Name = "Name";
            Position = UDim2.fromOffset(90, 6);
            Size = UDim2.fromOffset(140, 55);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = Pack.Name;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextScaled = true;
            TextSize = 24;
            TextWrapped = true;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(122, 57, 62);
                Thickness = 3;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Rays";
            Position = UDim2.fromOffset(-41 + 400 / 2, 29 + 400 / 2);
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.fromOffset(400, 400);
            BackgroundTransparency = 1;
            Image = "rbxassetid://97163599633952";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 3;
            Rotation = Rotation;
        };
        Blend.New "ImageLabel" {
            Name = "Pack";
            Position = UDim2.fromOffset(3, 71);
            Size = UDim2.fromOffset(312, 307);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://117805732973629";
            ZIndex = 4;
        };
        GenericButtonComponent({
            Name = "Buy";
            Position = UDim2.fromOffset(172 + 134 / 2, 387 + 54 / 2);
            Size = UDim2.fromOffset(134, 54);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://132032011692197";
            ZIndex = 5;
            OnPressed = function()
                props.BuyPack(Pack.Id)
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(5, 5);
                    Size = UDim2.fromOffset(124, 41);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Buy";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 20;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(14, 100, 13);
                        Thickness = 2;
                    };
                };
            }
        });
        Blend.New "Frame" {
            Name = "CurrencyBox";
            Position = UDim2.fromOffset(12, 387);
            Size = UDim2.fromOffset(134, 54);
            BackgroundTransparency = 1;
            ZIndex = 6;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromOffset(134, 54);
                BackgroundTransparency = 1;
                Image = "rbxassetid://117688671611190";
            };
            Blend.New "ImageLabel" {
                Name = "Coin";
                Position = UDim2.fromOffset(7, 2);
                Size = UDim2.fromOffset(50, 50);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://124297337927177";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
            Blend.New "TextLabel" {
                Name = "Amount";
                Position = UDim2.fromOffset(52, 2);
                Size = UDim2.fromOffset(80, 50);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = NumberLocalizationUtils.abbreviate(PackPrice, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 24;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(122, 57, 62);
                    Thickness = 2;
                };
            };
        };
        Blend.New "ImageLabel" {
            Name = "Info";
            Position = UDim2.fromOffset(12, 17);
            Size = UDim2.fromOffset(30, 32);
            BackgroundTransparency = 1;
            Image = "rbxassetid://134370064066838";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 7;
        };
        Blend.New "TextLabel" {
            Name = "Stock";
            Position = UDim2.fromOffset(257, 6);
            Size = UDim2.fromOffset(55, 55);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = Blend.Computed(Pack.Left, function(left: number)
                return tostring(left) .. "/" .. tostring(Pack.Stock)
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 20;
            ZIndex = 8;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(122, 57, 62);
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
