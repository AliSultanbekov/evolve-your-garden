--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local PackStoreTypesClient = require("PackStoreTypesClient")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")

local Background = require(script.Parent._Background)
local TabButtons = require(script.Parent._TabButtons)
local Tabs = require(script.Parent._Tabs)
local Title = require(script.Parent._Title)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Window = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PackStore";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1241, 722);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        Children = {
            Title(),
            Background() :: any,
            CloseButtonComponent({
                Name = "Close",
                Position = UDim2.fromOffset(1160+69/2, 46+69/2);
                Size = UDim2.fromOffset(66, 69);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
            });
            TabButtons({
                ActiveTab = props.ActiveTab,
                SwitchTab = props.SwitchTab
            });
            Tabs({
                Packs = props.Packs,
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
    ActiveTab: Observable.Observable<string>,

    SwitchTab: (tabName: string) -> (),
    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}
type ModuleData = {}

export type Module = typeof(Window) & ModuleData

return Window :: Module