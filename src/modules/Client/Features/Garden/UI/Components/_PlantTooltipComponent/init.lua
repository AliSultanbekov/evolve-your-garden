--[=[
    @class PlantTooltipComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Components ] --
local TooltipShellComponent = require("TooltipShellComponent")
local Buttons = require(script._Buttons)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local PlantTooltipComponent = function(props: Props)
    return TooltipShellComponent({
        Item = props.Item,
        Position = props.Position,
        AnchorPoint = Vector2.new(0, 0),
        PaddingBottom = 4,
        Content = function(displayItem, _isOpen)
            return {
                Buttons({
                    Item = displayItem,
                    IsSelected = props.IsSelected,
                    Actions = props.Actions
                });
            }
        end,
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

export type Module = typeof(PlantTooltipComponent) & ModuleData

return PlantTooltipComponent :: Module
