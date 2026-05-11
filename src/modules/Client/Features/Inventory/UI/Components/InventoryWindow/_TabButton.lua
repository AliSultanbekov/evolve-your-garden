--[=[
    @class TabButton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --
local GenericButton = require("GenericButton")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TabButton = function(props: Props)
    local TabName = props.TabName

    return GenericButton({
        Size = UDim2.fromOffset(100,100),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(64, 179, 255),
        BackgroundTransparency = 0,
        OnPressed = function () props.OnTabSwitched(TabName) end,
        Children = {
            Blend.New "UICorner" {
                CornerRadius = UDim.new(0, 5)
            },
            Blend.New "UIStroke" {
                Thickness = 4,
                Color = Color3.fromRGB(36, 66, 125)
            },
        },
    })
end

-- [ Types ] --
type Props = {
    TabName: string,
    OnTabSwitched: (tabName: string) -> ()
}
type ModuleData = {}

export type Module = typeof(TabButton) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return TabButton :: Module