--[=[
    @class Merchant
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ScreenSizeUtils = require("ScreenSizeUtils")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local MerchantTypesClient = require("MerchantTypesClient")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local Tabs = require(script._Tabs)
local Bookmarks = require(script._Bookmarks)
local RefreshTime = require(script._RefreshTime)
local SearchBar = require(script._SearchBar)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function Title()
    return Blend.New "Frame" {
        Name = "Title";
        LayoutOrder = 3;
        Position = UDim2.fromOffset(4, 4);
        Size = UDim2.fromOffset(434, 83);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 5;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(162, 15);
            Size = UDim2.fromOffset(209, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Merchant";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 48;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "ImageLabel" {
            Name = "MarketStall";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-12, -80);
            Size = UDim2.fromOffset(180, 180);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://93856043078136";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
    }
end

-- [ Module Table ] --
local Merchant = function(props: Props)
    return AnimatedFrameComponent({
        Name = "Merchant",
        -- The SearchBar/RefreshTime drawers hang ~100px below the 650-tall
        -- window (content spans 0..750). Shift the window up by half the
        -- overhang (scaled) so the TOTAL content is vertically centered —
        -- otherwise the drawers clip off the bottom on phones at min scale.
        Position = Blend.Computed(ScreenSizeUtils.ComputeScale(), function(scale: number)
            return UDim2.new(0.5, 0, 0.5, math.round(-50 * scale))
        end),
        Size = UDim2.fromOffset(1084, 655),
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        ApplyDeviceScale = true;
        IsOpen = props.IsOpen;
        
        Children = {
            SearchBar({
                OnSearch = props.OnSearch,
                ActiveTab = props.ActiveTab
            });
            Bookmarks({
                ActiveTab = props.ActiveTab,
                SwitchTab = props.SwitchTab,
            });
            Tabs({
                ActiveTab = props.ActiveTab,
                Items = props.Items,
                Search = props.Search,
                BuySlots = props.BuySlots,
                LastRefresh = props.LastRefresh,
                Buy = props.Buy,
                ItemPressed = props.ItemPressed,
                ItemHovered = props.ItemHovered,
                ItemUnhovered = props.ItemUnhovered
            });
            Title();
            RefreshTime({
                LastRefresh = props.LastRefresh,
                ActiveTab = props.ActiveTab
            });
            CloseButtonComponent({
                Name = "Close";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(1006, 10);
                Size = UDim2.fromOffset(68, 71);
                BackgroundTransparency = 1;
                ZIndex = 3;
                OnClose = function()
                    props.OnClose()
                end;
            });
            Blend.New "ImageLabel" {
                Name = "Background";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(0, 0);
                Size = UDim2.fromOffset(1161, 688);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://80625692429182";
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
    LastRefresh: Observable.Observable<number?>,

    SwitchTab: (tab: string) -> (),
    Buy: (slotId: string) -> (),
    OnSearch: (text: string) -> (),
    OnClose: () -> (),
    ItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    ItemHovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
    ItemUnhovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
}
type ModuleData = {}

export type Module = typeof(Merchant) & ModuleData

return Merchant :: Module