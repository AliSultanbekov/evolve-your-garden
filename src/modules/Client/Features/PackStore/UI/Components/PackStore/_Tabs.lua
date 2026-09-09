--[=[
    @class Tabs
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local PackStoreTypesClient = require("PackStoreTypesClient")
local RxBrioUtils = require("RxBrioUtils")
local Rx = require("Rx")
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
local function FormatHMMSS(seconds: number): string
    return string.format("%d:%02d:%02d", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60), math.floor(seconds % 60))
end

local Banner = function(props: BannerProps)
    local Now = Rx.fromSignal(RunService.Heartbeat):Pipe({
        Rx.map(function()
            return DateTime.now().UnixTimestamp
        end) :: any,
        Rx.startWith({ DateTime.now().UnixTimestamp }) :: any,
        Rx.distinct() :: any,
    })

    local TimeLeft = Rx.combineLatest({
        StartTime = props.StartTime,
        Now = Now,
    }):Pipe({
        Rx.map(function(data: any): any
            if not data.StartTime then
                return nil
            end

            return math.max(0, (data.StartTime + PackStoreConfig.SaleDuration) - data.Now)
        end) :: any,
        Rx.distinct() :: any,
    })

    return Blend.New "ImageLabel" {
        Name = "Banner";
        Size = UDim2.fromOffset(974, 125);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        Image = ImagesConfig.PackStore.Banners[props.TabName];
        ScaleType = Enum.ScaleType.Fit;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(322, 37);
            Size = UDim2.fromOffset(329, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = props.TabName .. " Packs";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 48;
            TextWrapped = true;
            TextYAlignment = Enum.TextYAlignment.Top;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "Frame" {
            Name = "RefreshTime";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(760, 20);
            Size = UDim2.fromOffset(191, 86);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 2;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromOffset(191, 86);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://136963150546507";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "Frame" {
                Name = "Icon";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(11, 10);
                Size = UDim2.fromOffset(65, 65);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 2;
                Blend.New "ImageLabel" {
                    Name = "Union";
                    Position = UDim2.fromOffset(1, 1);
                    Size = UDim2.fromOffset(61, 62);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://75208048469252";
                    ScaleType = Enum.ScaleType.Fit;
                };
                Blend.New "ImageLabel" {
                    Name = "Clock";
                    LayoutOrder = 1;
                    Size = UDim2.fromOffset(65, 65);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://125566711979383";
                    ZIndex = 2;
                };
            };
            Blend.New "TextLabel" {
                Name = "Title";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(82, 18);
                Size = UDim2.fromOffset(100, 50);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = Blend.Computed(TimeLeft, function(timeLeft: number?)
                    if not timeLeft then
                        return "Refresh in:"
                    end

                    return "Refresh in: " .. FormatHMMSS(timeLeft)
                end);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 19;
                TextWrapped = true;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(91, 64, 30);
                    Thickness = 3;
                };
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
        Size = UDim2.fromOffset(994, 608);
        BackgroundTransparency = 1;
        Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return if activeTab == props.TabName then true else false
        end);
        Blend.New "CanvasGroup" {
            Name = "Canvas";
            Size = UDim2.fromOffset(994, 608);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 2;
            Blend.New "ScrollingFrame" {
                Name = "Grid";
                Size = UDim2.fromOffset(994, 608);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                Active = true;
                BackgroundTransparency = 1;
                ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarImageTransparency = 0.5;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 4;
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
                    TabName = props.TabName,
                    StartTime = props.StartTime
                });
                Blend.New "Frame" {
                    Name = "Cards";
                    LayoutOrder = 1;
                    Size = UDim2.fromOffset(974, 0);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    ZIndex = 2;
                    Blend.New "UIGridLayout" {
                        CellPadding = UDim2.fromOffset(10, 10);
                        CellSize = UDim2.fromOffset(318, 453);
                        SortOrder = Enum.SortOrder.Name;
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
            StartTime = props.StartTime,
            BuyPack = props.BuyPack,
        }))
    end

    table.insert(Children, Blend.New "ImageLabel" {
        Name = "Background";
        Position = UDim2.fromOffset(-3, -3);
        Size = UDim2.fromOffset(1000, 613);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        Image = "rbxassetid://79493725272248";
        ScaleType = Enum.ScaleType.Fit;
        ZIndex = 0
    } :: any)

    return Blend.New "Frame" {
        Name = "Tabs";
        Position = UDim2.fromOffset(17, 108);
        Size = UDim2.fromOffset(994, 608);
        BackgroundTransparency = 1;
        ZIndex = 5;
        Children
    }
end

-- [ Types ] --
type Props = {
    Packs: PackStoreTypesClient.Packs,
    StartTime: Observable.Observable<number?>,
    ActiveTab: ComponentTypes.Prop<string>,
    AnimateEffects: Observable.Observable<boolean>,

    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}
type TabProps = {
    TabName: string,
    ActiveTab: ComponentTypes.Prop<string>,
    AnimateEffects: Observable.Observable<boolean>,
    Packs: PackStoreTypesClient.Packs,
    StartTime: Observable.Observable<number?>,

    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}
type BannerProps = {
    TabName: string,
    StartTime: Observable.Observable<number?>,
}

type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

return Tabs :: Module