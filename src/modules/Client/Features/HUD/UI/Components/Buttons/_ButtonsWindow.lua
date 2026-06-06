--[=[
    @class ButtonsWindow
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local ButtonsWindow = function(props: Props)
    return AnimatedFrameComponent({
        Name = "Buttons";
        Position = UDim2.fromScale(0, 0.5);
        Size = UDim2.fromOffset(206, 315);
        AnchorPoint = Vector2.new(0, 0.5);
        BackgroundTransparency = 1;
        Children = {
            Blend.New "UIPadding" {
                PaddingLeft = UDim.new(0, 5)
            };
            Blend.New "UIGridLayout" {
                CellPadding = UDim2.fromOffset(5, 5);
                CellSize = UDim2.fromOffset(98, 102);
                FillDirection = Enum.FillDirection.Horizontal;
            };
            GenericButtonComponent({
                Name = "Inventory";
                Size = UDim2.fromOffset(98, 102);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://92761967690607";
                OnPressed = function()
                    props.OnToggleUI("Inventory")
                end
            });
            GenericButtonComponent({
                Name = "PackStore";
                Size = UDim2.fromOffset(98, 102);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://92761967690607";
                OnPressed = function()
                    props.OnToggleUI("PackStore")
                end
            });
        };
        IsOpen = props.IsOpen
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    OnToggleUI: (uiName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(ButtonsWindow) & ModuleData

return ButtonsWindow :: Module