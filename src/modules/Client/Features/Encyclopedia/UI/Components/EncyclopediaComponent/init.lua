--[=[
    @class EncyclopediaComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
--local Blend = require("Blend")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")
local EncyclopediaTypesClient = require("EncyclopediaTypesClient")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local SearchBarComponent = require("SearchBarComponent")
local Background = require(script._Background)
local Bookmarks = require(script._Bookmarks)
local Tabs = require(script._Tabs)
local Title = require(script._Title)


-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EncyclopediaComponent = function(props: Props)
    return AnimatedFrameComponent({
        Name = "Encyclopedia";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1162, 768);
        BackgroundTransparency = 1;
        ApplyDeviceScale = true;
        IsOpen = props.IsOpen;
        Children = {
            Background(),
            Bookmarks({
                ActiveTab = props.ActiveTab,
                ClaimableCount = props.ClaimableCount,
                SwitchTab = props.SwitchTab,
            }),
            Tabs({
                DiscoveredPlantsCount = props.DiscoveredPlantsCount,
                ActiveTab = props.ActiveTab,
                GetDiscoveredItem = props.GetDiscoveredItem,
                SwitchTab = props.SwitchTab,
            }),
            Title(),
            SearchBarComponent({
                Size = UDim2.fromOffset(335, 71);
                BackgroundImage = "rbxassetid://74282051072934";
                SearchBoxSize = UDim2.fromOffset(324, 59);
                Position = UDim2.fromOffset(324, 59);
                SearchBoxPosition = UDim2.fromOffset(6, 6);
                OnSearch = props.OnSearch;
            }),
            CloseButtonComponent({
                Name = "Close";
                LayoutOrder = 5;
                Position = UDim2.fromOffset(1083, 10);
                Size = UDim2.fromOffset(68, 71);
                BackgroundTransparency = 1;
                ZIndex = 6;
                OnClose = function()
                    props.OnClose()
                end;
            })
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    ActiveTab: ComponentTypes.Prop<string>,
    ClaimableCount: Observable.Observable<number>,
    DiscoveredPlantsCount: Observable.Observable<number>,
    OnClose: () -> (),
    OnSearch: (text: string) -> (),
    SwitchTab: (tabName: string) -> (),
    GetDiscoveredItem: (itemName: string) -> EncyclopediaTypesClient.ReactiveDiscoveredItem
}
type ModuleData = {}

export type Module = typeof(EncyclopediaComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return EncyclopediaComponent :: Module