--[=[
    @class Bookmarks

    Merchant bookmark rail (Buy / Sell). The merchant art is two layers:
    the bookmark frame is the button image, the colored plate overlays it —
    both dim with the shared tint.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Components ] --
local BookmarksComponent = require("BookmarksComponent")

-- [ Constants ] --
local TABS = { "Buy", "Sell" }

-- [ Variables ] --

-- [ Functions ] --
local function PlateOverlay(tint: any)
    return {
        Blend.New "ImageLabel" {
            Name = "Background";
            Position = UDim2.fromOffset(-1, 0);
            Size = UDim2.fromOffset(307, 104);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://89760672643276";
            ImageColor3 = tint;
            ScaleType = Enum.ScaleType.Fit;
        };
    }
end

-- [ Module Table ] --
local Bookmarks = function(props: Props)
    local Tabs: { BookmarksComponent.Tab } = {}

    for _, tabName in TABS do
        table.insert(Tabs, {
            Name = tabName,
            Children = PlateOverlay,
        })
    end

    return BookmarksComponent({
        ActiveTab = props.ActiveTab,
        SwitchTab = props.SwitchTab,
        Tabs = Tabs,

        Image = "rbxassetid://91262575718707",
        LabelSize = UDim2.fromOffset(130, 37),
        TextSize = 29,
    })
end

-- [ Types ] --
type Props = {
    ActiveTab: Observable.Observable<string>,
    SwitchTab: (string) -> (),
}
type ModuleData = {}

export type Module = typeof(Bookmarks) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Bookmarks :: Module
