--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local _Blend = require("Blend")
local Observable = require("Observable")
local InventoryTypesClient = require("InventoryTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local Title = require(script.Parent._Title)
local SearchBar = require(script.Parent._SeachBar)
local Background = require(script.Parent._Background)
local Tabs = require(script.Parent._Tabs)
local TabButtons = require(script.Parent._TabButtons)
local Buttons = require(script.Parent._Buttons)

local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Window = function(props: Props)
    return AnimatedFrameComponent({
        Name = "Inventory",
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
            SearchBar({
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
    
    GetItems: (filter: string?) -> InventoryTypesClient.Items,
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