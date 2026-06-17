
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
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local Background = require(script.Parent._Background)
local Top = require(script.Parent._Top)
local Buttons = require(script.Parent._Buttons)

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

    local Position = Rx.combineLatest({
        Item = props.Item,
        Position = props.Position,
    }):Pipe({
        Rx.where(function(data) return data.Item ~= nil and data.Position ~= nil end) :: any,
        Rx.map(function(data)
            local pos: UDim2 = data.Position
            return UDim2.fromOffset(pos.X.Offset + 80, pos.Y.Offset + 50)
        end) :: any
    })

    return AnimatedFrameComponent({
        Name = "Tooltip";
        Position = Position;
        AnchorPoint = Vector2.new(0, 0.5);
        Size = UDim2.fromOffset(256, 0);
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
                    Blend.New "UIPadding" {
                        PaddingBottom = UDim.new(0, 3)
                    },
                    Top({
                        Item = DisplayItem,
                        AnimateEffects = IsOpen,
                    }),
                    Buttons({
                        Item = DisplayItem,
                        IsSelected = props.IsSelected,

                        Actions = props.Actions,

                        OnClose = props.OnClose,
                    })
                }
            }
        }
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    IsSelected: Observable.Observable<boolean>,
    Position: Observable.Observable<UDim2?>,
    Actions: InventoryTypesClient.Actions,

    OnClose: () -> (),
}

type ModuleData = {}

export type Module = typeof(Window) & ModuleData

return Window :: Module