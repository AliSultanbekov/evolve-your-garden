--[=[
    @class InventoryTab
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local InventoryTypesClient = require("InventoryTypesClient")
local ItemTypes = require("ItemTypes")
local Observable = require("Observable")

-- [ Components ] --
local ItemsGrid = require("ItemsGrid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryTab = function(props: Props)
    local TabName = props.TabName
    local ActiveTab = props.ActiveTab

    return Blend.New "Frame" {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = Blend.Computed(ActiveTab, function(tabName: string)
            return if tabName == TabName then true else false
        end),
        [Blend.Children] = {
            Blend.New "UIListLayout" {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            },
            ItemsGrid({ Items = props.Items, ItemCategories = props.ItemCategories })
        }
    }
end

-- [ Types ] --
type Props = {
    Items: InventoryTypesClient.Items,
    ItemCategories: { [ItemTypes.Category]: boolean },
    TabName: string,
    ActiveTab: Observable.Observable<string>,
}
type ModuleData = {}

export type Module = typeof(InventoryTab) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryTab :: Module