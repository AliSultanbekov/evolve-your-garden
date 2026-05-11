--[=[
    @class PlantPickerWindow
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local GenericBackgroundComponent = require("GenericBackgroundComponent")
local GenericSkeletonComponent = require("GenericSkeletonComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local ItemsGridComponent = require("ItemsGridComponent")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantPickerWindowComponent = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PlantPicker",
        Size = UDim2.fromOffset(900, 565),
        IsOpen = props.IsOpen,
        Children = {
            GenericSkeletonComponent({
                Header = {
                    Size = UDim2.new(1, 0, 0, 60),
                    Position = UDim2.fromScale(0.5, 0),
                    AnchorPoint = Vector2.new(0.5,0),
                    Children = {
                        CloseButtonComponent({
                            Position = UDim2.new(1, -26, 0, 26),
                            OnClose = props.OnClose
                        }
                    )}
                },
                Body = {
                    Size = UDim2.new(1, 0, 1, -60),
                    Position = UDim2.fromScale(0.5, 1),
                    AnchorPoint = Vector2.new(0.5,1),
                    Children = {
                        ItemsGridComponent({
                            Size = UDim2.fromScale(1, 1),
                            Position = UDim2.fromScale(0.5, 1),
                            AnchorPoint = Vector2.new(0.5, 1),
                            Items = props.Items,
                            ItemCategories = {["Plant"] = true},
                            OnItemPressed = props.OnItemPressed
                        })
                    }
                }
            }),
            GenericBackgroundComponent()
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    Items: InventoryTypesClient.Items,
    OnClose: () -> (),
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem) -> ()
}
type ModuleData = {}

export type Module = typeof(PlantPickerWindowComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantPickerWindowComponent :: Module