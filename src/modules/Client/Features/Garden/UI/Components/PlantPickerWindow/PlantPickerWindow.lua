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
local AnimatedFrame = require("AnimatedFrame")
local GenericBackground = require("GenericBackground")
local GenericSkeleton = require("GenericSkeleton")
local CloseButton = require("CloseButton")
local ItemsGrid = require("ItemsGrid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantPickerWindow = function(props: Props)
    return AnimatedFrame({
        Name = "PlantPicker",
        Size = UDim2.fromOffset(900, 565),
        IsOpen = props.IsOpen,
        Children = {
            GenericSkeleton({
                Header = {
                    Size = UDim2.new(1, 0, 0, 60),
                    Position = UDim2.fromScale(0.5, 0),
                    AnchorPoint = Vector2.new(0.5,0),
                    Children = {
                        CloseButton({
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
                        ItemsGrid({
                            Size = UDim2.fromScale(1, 1),
                            Position = UDim2.fromScale(0.5, 1),
                            AnchorPoint = Vector2.new(0.5, 1),
                            Items = props.Items,
                            ItemCategories = {["Plant"] = true}
                        })
                    }
                }
            }),
            GenericBackground()
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    Items: InventoryTypesClient.Items,
    OnClose: () -> (),
}
type ModuleData = {}

export type Module = typeof(PlantPickerWindow) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantPickerWindow :: Module