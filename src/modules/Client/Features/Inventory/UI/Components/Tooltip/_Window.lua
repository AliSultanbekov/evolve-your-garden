
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
local Background = require(script.Parent._Background)
local Top = require(script.Parent._Top)

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

    local Position = props.Position:Pipe({
        Rx.where(function(item) return item ~= nil end) :: any,
        Rx.map(function(pos: UDim2) return UDim2.fromOffset(pos.X.Offset + 80, pos.Y.Offset + 50) end) :: any
    })

    return AnimatedFrameComponent({
        Name = "Tooltip";
        Position = Position;
        AnchorPoint = Vector2.new(0, 0.5);
        Size = UDim2.fromOffset(255, 150);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        IsOpen = IsOpen;
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
                    Top({
                        Item = DisplayItem,
                        AnimateEffects = IsOpen,
                    })
                }
            }
        }
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    Position: Observable.Observable<UDim2?>,
}

type ModuleData = {}

export type Module = typeof(Window) & ModuleData

return Window :: Module