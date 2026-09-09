--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")
local PackStoreTypesClient = require("PackStoreTypesClient")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")

local Background = require(script._Background)
local Bookmarks = require(script._Bookmarks)
local Tabs = require(script._Tabs)
local Title = require(script._Title)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Window = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PackStore";
        ApplyDeviceScale = true;
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1028, 733);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        Children = {
            Title(),
            Background() :: any,
            CloseButtonComponent({
                Name = "Close",
                Position = UDim2.fromOffset(950 + 68/2, 10 + 71/2);
                Size = UDim2.fromOffset(68, 71);
                ZIndex = 3;
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                OnClose = function()
                    props.OnClose()
                end;
            });
            Bookmarks({
                ActiveTab = props.ActiveTab,
                SwitchTab = props.SwitchTab
            });
            Tabs({
                Packs = props.Packs,
                StartTime = props.StartTime,
                ActiveTab = props.ActiveTab,
                AnimateEffects = props.IsOpen,
                BuyPack = props.BuyPack
            })
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    Packs: PackStoreTypesClient.Packs,
    StartTime: Observable.Observable<number?>,
    ActiveTab: ComponentTypes.Prop<string>,

    SwitchTab: (tabName: string) -> (),
    BuyPack: (packId: PackStoreTypesShared.PackId) -> (),
    OnClose: () -> (),
}
type ModuleData = {}

export type Module = typeof(Window) & ModuleData

return Window :: Module