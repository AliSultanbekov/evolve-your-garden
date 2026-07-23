--[=[
    @class ItemTooltipComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Components ] --
local TooltipShellComponent = require("TooltipShellComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local ItemTooltipComponent = function(props: Props)
    return TooltipShellComponent({
        Item = props.Item,
        Position = props.Position,
        AnchorPoint = Vector2.new(0, 0.5),
        PaddingBottom = 3,
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    Position: Observable.Observable<UDim2>,
}

type ModuleData = {}

export type Module = typeof(ItemTooltipComponent) & ModuleData

return ItemTooltipComponent :: Module
