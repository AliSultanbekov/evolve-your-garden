--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local _Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local Title = require(script._Title)
local Background = require(script._Background)
local Tabs = require(script._Tabs)
local Bookmark = require(script._Bookmarks)
local Buttons = require(script._Buttons)

local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local SearchBarComponent = require("SearchBarComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Window = function(props: Props)
    return AnimatedFrameComponent({
        Name = "Inventory",
        ApplyDeviceScale = true,
        Size = UDim2.fromOffset(1086, 657);
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        Children = {
            Background() :: any;
            Bookmark({
                ActiveTab = props.ActiveTab;
                SwitchTab = props.SwitchTab;
            });
            Tabs({
                ActiveTab = props.ActiveTab;
                Search = props.Search;
                GetItems = props.GetItems;
                OnItemPressed = props.OnItemPressed :: any;
                OnItemHovered = props.OnItemHovered :: any;
                OnItemUnhovered = props.OnItemUnhovered :: any;
            });
            SearchBarComponent({
                Position = UDim2.fromOffset(666, 10);
                Size = UDim2.fromOffset(336, 72);
                ZIndex = 4;
                BackgroundImage = "rbxassetid://74282051072934";
                SearchBoxPosition = UDim2.fromOffset(6, 6);
                SearchBoxSize = UDim2.fromOffset(324, 59);
                TextBoxStrokeColor =  Color3.fromRGB(43, 73, 112);
                
                OnSearch = props.OnSearch;
            });
            Buttons({
                DeleteMode = props.DeleteMode;
                OnDeleteMode = props.OnDeleteMode;
            });
            Title();
            CloseButtonComponent({
                Position = UDim2.fromOffset(1042, 45);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromOffset(68, 71);
                BackgroundTransparency = 1;
                Image = "rbxassetid://121697259395490";
                ZIndex = 6;
                OnClose = function()
                    props.OnClose()
                end;
            });
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: ComponentTypes.Prop<boolean>,
    ActiveTab: ComponentTypes.Prop<string>,
    Search: Observable.Observable<string>,
    DeleteMode: Observable.Observable<boolean>,

    GetItems: (filter: string?) -> ReactiveItemTypes.ReactiveItems,
    SwitchTab: (tabName: string) -> (),
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
    OnClose: () -> (),
    OnSearch: (text: string) -> (),
    OnDeleteMode: () -> (),
}
type ModuleData = {}

export type Module = typeof(Window) & ModuleData

return Window :: Module