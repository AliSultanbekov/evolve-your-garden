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
local ImageConfig = require("ImageConfig")
local PacksConfig = require("PacksConfig")
local Rx = require("Rx")
local Observable = require("Observable")
local PackStoreConfig = require("PackStoreConfig")
local NumberLocalizationUtils = require("NumberLocalizationUtils")
local RoundingBehaviourTypes = require("RoundingBehaviourTypes")
local PackStoreTypesShared = require("PackStoreTypesShared")

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
    local PackRarity = PacksConfig.Packs[Pack.Name].Rarity
    local PackPrice = PackStoreConfig.Prices[Pack.Category][Pack.Name].Amount
    local _PackCurrency = nil

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
        Position = UDim2.fromOffset(167, 152);
        Size = UDim2.fromOffset(323, 543);
        BackgroundTransparency = 1;
        ZIndex = 1;
        Blend.New "ImageLabel" {
            Name = "Glow";
            Position = UDim2.fromOffset(-13, -13);
            Size = UDim2.fromOffset(349, 569);
            BackgroundTransparency = 1;
            Image = ImageConfig.PackStore.PackCardRarityGlows[PackRarity];
            
            ZIndex = -2;
        };
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromOffset(323, 543);
            BackgroundTransparency = 1;
            Image = "rbxassetid://125032423801149";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = -1;
        };
        Blend.New "ImageLabel" {
            Name = "Rays";
            Position = UDim2.fromOffset(-61, 12);
            Size = UDim2.fromOffset(445, 445);
            BackgroundTransparency = 1;
            Image = "rbxassetid://90114129986983";
            ZIndex = 2;
            Rotation = Rotation
        };
        Blend.New "ImageLabel" {
            Name = "Pack";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(22, 48);
            Size = UDim2.fromOffset(276, 387);
            BackgroundTransparency = 1;
            Image = "rbxassetid://83313944132466";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 3;
        };
        Blend.New "TextLabel" {
            Name = "Stock";
            Position = UDim2.fromOffset(235, 8);
            Size = UDim2.fromOffset(80, 50);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            Text = Blend.Computed(Pack.Left, function(left: number)
                return tostring(left) .. "/" .. tostring(Pack.Stock)
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 24;
            ZIndex = 3;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(0, 71, 97);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 3;
            };
        };
        Blend.New "TextLabel" {
            Name = "Name";
            Position = UDim2.fromOffset(68, -28);
            Size = UDim2.fromOffset(186, 52);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            Text = Pack.Name;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 28;
            TextWrapped = true;
            ZIndex = 3;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(0, 71, 97);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 3;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Rarity";
            Position = UDim2.fromOffset(14, 15);
            Size = UDim2.fromOffset(131, 41);
            BackgroundTransparency = 1;
            Image = ImageConfig.PackStore.RarityImages[PackRarity];
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 3;
        };
        GenericButtonComponent({
            Name = "Buy";
            Position = UDim2.fromOffset(166+141/2, 467+61/2);
            Size = UDim2.fromOffset(141, 61);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://120462236037534";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 3;
            OnPressed = function()
                props.BuyPack(Pack.Id)
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Price";
                    Position = UDim2.fromOffset(6, 11);
                    Size = UDim2.fromOffset(128, 34);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                    Text = "Buy";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 34;
                    ZIndex = 3;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(6, 90, 0);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 3;
                    };
                };
            }
        });
        --[[Blend.New "Frame" {
            Name = "Locked";
            Size = UDim2.fromOffset(323, 543);
            BackgroundTransparency = 1;
            Visible = false;
            ZIndex = 100;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromScale(1, 1);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://129228536819931";
            };
            Blend.New "ImageLabel" {
                Name = "Lock";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(90, 141);
                Size = UDim2.fromOffset(139, 139);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://107871333816720";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
            Blend.New "TextLabel" {
                Name = "Text";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(38, 280);
                Size = UDim2.fromOffset(247, 58);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                Text = "Level 20 Garden Required";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 24;
                TextWrapped = true;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(27, 27, 27);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 4;
                };
            };
        };]]
        Blend.New "Frame" {
            Name = "CurrencyBox";
            Position = UDim2.fromOffset(20, 470);
            Size = UDim2.fromOffset(135, 55);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://131851695546524";
            };
            Blend.New "ImageLabel" {
                Name = "Currency";
                Position = UDim2.fromOffset(8, 4);
                Size = UDim2.fromOffset(47, 46);
                BackgroundTransparency = 1;
                Image = "rbxassetid://83218620453911";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
            Blend.New "TextLabel" {
                Name = "Price";
                Position = UDim2.fromOffset(52, 8);
                Size = UDim2.fromOffset(77, 39);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                Text = NumberLocalizationUtils.abbreviate(PackPrice, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 24;
                TextWrapped = true;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(0, 71, 97);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 3;
                };
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