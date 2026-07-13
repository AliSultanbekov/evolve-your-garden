--[=[
    @class Merchant
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local MerchantTypesClient = require("MerchantTypesClient")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local Tabs = require(script._Tabs)
local TabButtons = require(script._TabButtons)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function Title()
    return Blend.New "Frame" {
        Name = "Title";
        LayoutOrder = 3;
        Size = UDim2.fromOffset(413, 88);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(173, 16);
            Size = UDim2.fromOffset(193, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Merchant";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 40;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(97, 61, 34);
                Thickness = 4;
            };
        };
        Blend.New "ImageLabel" {
            Name = "MarketStall";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-6, -82);
            Size = UDim2.fromOffset(180, 180);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://136914917414862";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
    }
end

-- [ Module Table ] --
local Merchant = function(props: Props)
    return AnimatedFrameComponent({
        Name = "Merchant",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1078, 650),
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        ApplyDeviceScale = true;
        IsOpen = props.IsOpen;
        
        Children = {
            TabButtons({
                ActiveTab = props.ActiveTab,
                SwitchTab = props.SwitchTab,
            });
            Tabs({
                ActiveTab = props.ActiveTab,
                Items = props.Items,
                Search = props.Search,
                BuySlots = props.BuySlots
            });
            Title();
            CloseButtonComponent({
                Name = "Close";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(1008, 9);
                Size = UDim2.fromOffset(61, 64);
                BackgroundTransparency = 1;
                ZIndex = 3;
            });
            Blend.New "ImageLabel" {
                Name = "Background";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(-4, -4);
                Size = UDim2.fromOffset(1086, 658);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://136798597515749";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            }
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    ActiveTab: Observable.Observable<string>,
    Items: ReactiveItemTypes.ReactiveItems,
    Search: Observable.Observable<string>,
    BuySlots: MerchantTypesClient.ReactiveSlots,

    SwitchTab: (tab: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Merchant) & ModuleData

return Merchant :: Module