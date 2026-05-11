--[=[
    @class Window
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
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local GenericBackgroundComponent = require("GenericBackgroundComponent")
local GenericSkeletonComponent = require("GenericSkeletonComponent")
local TabComponent = require(script.Parent._TabComponent)
local NavBarComponent = require(script.Parent._NavBarComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WindowComponent = function(props: Props)
    local TabsConfig = props.TabsConfig

    return AnimatedFrameComponent({
        Name = "Inventory",
        Size = UDim2.fromOffset(900, 650),
        Position = UDim2.fromScale(0.5, 0.5),
        IsOpen = props.IsOpen,
        Children = {
            GenericSkeletonComponent({
                Header = {
                    Size = UDim2.new(1, 0, 0, 60),
                    Position = UDim2.fromScale(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Children = {
                        CloseButtonComponent({
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
                            return TabComponent({
                                Items = props.Items,
                                ItemCategories = itemCategories,
                                TabName = tabName,
                                ActiveTab = props.ActiveTab
                            })
                        end)
                    }
                }
            }),
            NavBarComponent({
                TabsConfig = TabsConfig,
                OnTabSwitched = props.OnTabSwitched,
            }),
            GenericBackgroundComponent(),
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

export type Module = typeof(WindowComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return WindowComponent :: Module