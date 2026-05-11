--[=[
    @class InventoryWindow
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local InventoryTypesClient = require("InventoryTypesClient")
local Blend = require("Blend")
local ItemTypes = require("ItemTypes")

-- [ Components ] --
local AnimatedFrame = require("AnimatedFrame")
local CloseButton = require("CloseButton")
local GenericBackground = require("GenericBackground")
local GenericSkeleton = require("GenericSkeleton")
local InventoryTab = require(script.Parent._InventoryTab)
local InventoryNavBar = require(script.Parent._InventoryNavBar)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryWindow = function(props: Props)
    local TabsConfig = props.TabsConfig

    return AnimatedFrame({
        Name = "Inventory",
        Size = UDim2.fromOffset(900, 650),
        Position = UDim2.fromScale(0.5, 0.5),
        IsOpen = props.IsOpen,
        Children = {
            GenericSkeleton({
                Header = {
                    Size = UDim2.new(1, 0, 0, 60),
                    Position = UDim2.fromScale(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Children = {
                        CloseButton({
                            OnClose = props.OnClose,
                            Position = UDim2.new(1, -26, 0, 26),
                            Size = UDim2.fromOffset(50,50),
                        })
                    },
                },
                Body = {
                    Size = UDim2.new(1, 0, 1, -60),
                    Position = UDim2.fromScale(0.5, 1),
                    AnchorPoint = Vector2.new(0.5, 1),
                    Children = {
                        Blend.ComputedPairs(TabsConfig, function(tabName: string, itemCategories: { [ItemTypes.Category]: boolean }, _)
                            return InventoryTab({
                                Items = props.Items,
                                ItemCategories = itemCategories,
                                TabName = tabName,
                                ActiveTab = props.ActiveTab
                            })
                        end)
                    }
                }
            }),
            InventoryNavBar({
                TabsConfig = TabsConfig,
                OnTabSwitched = props.OnTabSwitched,
            }),
            GenericBackground(),
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,

    Items: InventoryTypesClient.Items,
    TabsConfig: InventoryTypesClient.TabsConfig,
    ActiveTab: Observable.Observable<string>,

    OnTabSwitched: (tabName: string) -> (),
    OnClose: () -> (),
}
type ModuleData = {}

export type Module = typeof(InventoryWindow) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryWindow :: Module