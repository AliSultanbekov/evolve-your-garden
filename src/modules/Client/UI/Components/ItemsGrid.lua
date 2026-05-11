--[=[
    @class ItemsGrid
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local InventoryTypesClient = require("InventoryTypesClient")
local RxBrioUtils = require("RxBrioUtils")
local ItemTypes = require("ItemTypes")

-- [ Components ] --
local ItemCard = require("ItemCard")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemsGrid = function(props: Props)
    local Items = props.Items
    local ItemCategories = props.ItemCategories
    local Cards = (Items:ObserveValuesBrio():Pipe({
        RxBrioUtils.where(function(item) return ItemCategories[item.Category] == true end) :: any,
        RxBrioUtils.map(function(item) return ItemCard({ Item = item }) end) :: any,
    })) :: any

    return Blend.New "ScrollingFrame" {
        Size = props.Size or UDim2.new(1, 0, 1, -42.5),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        CanvasSize = UDim2.fromScale(0, 3),
        ScrollBarImageTransparency = 0.5,
        LayoutOrder = 1,
        [Blend.Children] = {
            Blend.New "UIPadding" {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            },
            Blend.New "UICorner" {
                CornerRadius = UDim.new(0, 10)
            },
            Blend.New "UIGridLayout" {
                CellPadding = UDim2.fromOffset(15, 15),
                CellSize = UDim2.fromOffset(110, 110)
            },
            Cards
        }
    }
end

-- [ Types ] --
type Props = {
    Size: UDim2?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Items: InventoryTypesClient.Items,
    ItemCategories: { [ItemTypes.Category]: boolean }
}
type ModuleData = {}

export type Module = typeof(ItemsGrid) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ItemsGrid :: Module