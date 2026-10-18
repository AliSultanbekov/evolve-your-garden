--[=[
    @class Background
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Background = function()
    return Blend.New "ImageButton" {
        Name = "Background";
        -- ImageButton (no handlers) so it occludes buttons sliding under the
        -- art: only GuiButtons block other GuiButtons in Roblox hit-testing;
        -- Active frames/images only sink world input.
        AutoButtonColor = false;
        Selectable = false;
        LayoutOrder = 1;
        Position = UDim2.fromOffset(0, 0);
        Size = UDim2.fromOffset(1086, 657);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        Image = "rbxassetid://96013219466539";
        ScaleType = Enum.ScaleType.Fit;
        ZIndex = 2;
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

return Background :: Module