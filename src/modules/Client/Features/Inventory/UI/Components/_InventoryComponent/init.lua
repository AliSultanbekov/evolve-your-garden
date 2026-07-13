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
local TabButtons = require(script._TabButtons)
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
        Size = UDim2.fromOffset(1223, 729);
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        Children = {
            Background() :: any;
            TabButtons({
                ActiveTab = props.ActiveTab;
                SwitchTab = props.SwitchTab;
            });
            Tabs({
                ActiveTab = props.ActiveTab;
                Search = props.Search;
                GetItems = props.GetItems;
                OnItemPressed = props.OnItemPressed;
                OnItemHovered = props.OnItemHovered;
                OnItemUnhovered = props.OnItemUnhovered;
            });
            SearchBarComponent({
                LayoutOrder = 3;
                Position = UDim2.fromOffset(831, 9);
                Size = UDim2.fromOffset(306, 64);
                ZIndex = 4;
                BackgroundImage = "rbxassetid://129977395166820";
                SearchBoxSize = UDim2.fromOffset(306, 64);
                OnSearch = props.OnSearch;
            });
            Buttons({
                OnDeleteMode = props.OnDeleteMode;
            });
            Title();
            CloseButtonComponent({
                Position = UDim2.fromOffset(1148+61/2, 9+61/2);
                Size = UDim2.fromOffset(61, 64);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://131155686671413";
                ZIndex = 3;
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