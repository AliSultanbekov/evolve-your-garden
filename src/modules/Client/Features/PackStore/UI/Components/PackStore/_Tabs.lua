--[=[
    @class Tabs
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local PackStoreTypesClient = require("PackStoreTypesClient")
local RxBrioUtils = require("RxBrioUtils")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")
local PackStoreConfig = require("PackStoreConfig")
local PackStoreTypesShared = require("PackStoreTypesShared")
local ImagesConfig = require("ImagesConfig")

-- [ Components ] --
local PackCard = require(script.Parent._PackCard)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local Banner = function(props: BannerProps)
    return Blend.New "Frame" {
        Name = "Banner";
        Size = UDim2.fromOffset(976, 125);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Banner";
            Size = UDim2.fromOffset(976, 125);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = ImagesConfig.PackStore.Banner[props.TabName];
        };
        Blend.New "TextLabel" {
            Name = "Title";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(338, 37);
            Size = UDim2.fromOffset(300, 50);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = props.TabName .. " Packs";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 40;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(67, 93, 94);
                Thickness = 4;
            };
        };
        Blend.New "Frame" {
            Name = "RefreshTime";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(758, 3);
            Size = UDim2.fromOffset(154, 76);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Blend.New "ImageLabel" {
                Name = "Background";
                Position = UDim2.fromOffset(-3, -3);
                Size = UDim2.fromOffset(160, 82);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://89905077680734";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "TextLabel" {
                Name = "Name";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(16, 8);
                Size = UDim2.fromOffset(122, 22);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = "Restock in:";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 20;
                ZIndex = 2;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(97, 61, 34);
                    Thickness = 2;
                };
            };
            Blend.New "TextLabel" {
                Name = "Time";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(53, 40);
                Size = UDim2.fromOffset(85, 20);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = "3:00:00";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 20;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(97, 61, 34);
                    Thickness = 2;
                };
            };
            Blend.New "ImageLabel" {
                Name = "Clock";
                LayoutOrder = 3;
                Position = UDim2.fromOffset(14, 33);
                Size = UDim2.fromOffset(34, 34);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://112248837592070";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 4;
            };
        };
    };
end

local Tab = function(props: TabProps)
    local PackCards = (props.Packs :: any):ObserveValuesBrio():Pipe({
        RxBrioUtils.where(function(pack: PackStoreTypesClient.ReactivePack)
            return pack.Category == props.TabName
        end),
        RxBrioUtils.map(function(pack: PackStoreTypesClient.ReactivePack)
            return PackCard({
                Pack = pack,
                AnimateEffects = props.AnimateEffects,
                BuyPack = props.BuyPack,
            })
        end) :: any,
    })

    return Blend.New "Frame" {
        Name = props.TabName;
        Size = UDim2.fromOffset(996, 608);
        BackgroundTransparency = 1;
        Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return if activeTab == props.TabName then true else false
        end);
        Blend.New "CanvasGroup" {
            Size = UDim2.fromOffset(996, 608);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Blend.New "ScrollingFrame" {
                Name = "Grid";
                Size = UDim2.fromOffset(996, 608);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                Active = true;
                BackgroundTransparency = 1;
                ScrollBarImageColor3 = Color3.fromRGB(110, 69, 38);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 6;
                Blend.New "UIListLayout" {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    Padding = UDim.new(0, 10);
                };
                Blend.New "UIPadding" {
                    PaddingBottom = UDim.new(0, 10);
                    PaddingLeft = UDim.new(0, 10);
                    PaddingRight = UDim.new(0, 10);
                    PaddingTop = UDim.new(0, 10);
                };
                Banner({
                    TabName = props.TabName
                });
                Blend.New "Frame" {
                    Name = "Packs";
                    LayoutOrder = 1;
                    Size = UDim2.fromOffset(976, 0);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    ZIndex = 2;
                    Blend.New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                        Padding = UDim.new(0, 11);
                        SortOrder = Enum.SortOrder.Name;
                        Wraps = true;
                    };
                    PackCards
                };
            };
        }
    };
end

-- [ Module Table ] --
local Tabs = function(props: Props)
    local Children = {}

    for _, category in PackStoreConfig.Categories do
        table.insert(Children, Tab({
            TabName = category,
            ActiveTab = props.ActiveTab,
            AnimateEffects = props.AnimateEffects,
            Packs = props.Packs,
            BuyPack = props.BuyPack,
        }))
    end

    return Blend.New "Frame" {
        Name = "Tabs";
        Position = UDim2.fromOffset(208, 96);
        Size = UDim2.fromOffset(996, 608);
        BackgroundTransparency = 1;
        Children
    }
end

-- [ Types ] --
type Props = {
    Packs: PackStoreTypesClient.Packs,
    ActiveTab: ComponentTypes.Prop<string>,
    AnimateEffects: Observable.Observable<boolean>,

    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}
type TabProps = {
    TabName: string,
    ActiveTab: ComponentTypes.Prop<string>,
    AnimateEffects: Observable.Observable<boolean>,
    Packs: PackStoreTypesClient.Packs,

    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}
type BannerProps = {
    TabName: string,
    
}

type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

return Tabs :: Module