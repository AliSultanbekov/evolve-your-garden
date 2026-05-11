--[=[
    @class NavBar
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Components ] --
local TabButtonComponent = require(script.Parent._TabButtonComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NavBarComponent = function(props: Props)
    return Blend.New "Frame" {
        Name = "NavBar",
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        [Blend.Children] = {
            Blend.New "UIListLayout" {
                Padding = UDim.new(0, 15),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            },
            Blend.New "UIPadding" {
                PaddingTop = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
            },
            Blend.ComputedPairs(props.TabsConfig, function(tabName: string, _, _)
                return TabButtonComponent({
                    TabName = tabName,
                    OnTabSwitched = props.OnTabSwitched
                })
            end)
        }
    }
end

-- [ Types ] --
type Props = {
    TabsConfig: InventoryTypesClient.TabsConfig,
    OnTabSwitched: (tabName: string) -> ()
}
type ModuleData = {}

export type Module = typeof(NavBarComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return NavBarComponent :: Module