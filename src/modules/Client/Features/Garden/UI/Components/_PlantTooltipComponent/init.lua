
--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local Background = require(script._Background)
local Top = require(script._Top)
local Buttons = require(script._Buttons)
local TooltipPlantStatsComponent = require("TooltipPlantStatsComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Window = function(props: Props)
    local Item = props.Item

    local DisplayItem: Observable.Observable<ReactiveItemTypes.ReactiveItem> = props.Item:Pipe({
        Rx.where(function(item) return item ~= nil end) :: any,
    }) :: any

    local IsOpen: Observable.Observable<boolean> = Item:Pipe({
        Rx.map(function(item)
            return item ~= nil
        end) :: any
    }) :: any
    
    return AnimatedFrameComponent({
        Name = "Tooltip";
        ApplyDeviceScale = true;
        Position = props.Position;
        AnchorPoint = Vector2.new(0, 0);
        Size = UDim2.fromOffset(256, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        IsOpen = IsOpen;
        ZIndex = 100,
        Children = {
            Background();
            Blend.New "Frame" {
                Name = "Container";
                Position = UDim2.fromScale(0.5, 0);
                AnchorPoint = Vector2.new(0.5, 0);
                Size = UDim2.fromScale(1, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                [Blend.Children] = {
                    Blend.New "UIListLayout" {};
                    Blend.New "UIPadding" {
                        PaddingBottom = UDim.new(0, 4)
                    },
                    Top({
                        Item = DisplayItem,
                        AnimateEffects = IsOpen,
                    }),
                    Buttons({
                        Item = DisplayItem,
                        IsSelected = props.IsSelected,
                        Actions = props.Actions
                    }),
                    TooltipPlantStatsComponent({
                        Item = DisplayItem :: any,
                    })
                }
            }
        }
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    Position: Observable.Observable<UDim2>,
    IsSelected: Observable.Observable<boolean>,
    Actions: { [string]: (...any) -> (...any) }
}

type ModuleData = {}

export type Module = typeof(Window) & ModuleData

return Window :: Module