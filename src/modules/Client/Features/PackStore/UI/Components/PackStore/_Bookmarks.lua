--[=[
    @class Bookmarks
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local ComponentTypes = require("ComponentTypes")
local PackStoreConfig = require("PackStoreConfig")

-- [ Components ] --
local BookmarksComponent = require("BookmarksComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Bookmarks = function(props: Props)
    local Tabs: { BookmarksComponent.Tab } = {}

    for _, category in PackStoreConfig.Categories do
        table.insert(Tabs, { Name = category })
    end

    return BookmarksComponent({
        ActiveTab = props.ActiveTab,
        SwitchTab = props.SwitchTab,
        Tabs = Tabs,

        Image = "rbxassetid://135454002783683",
        LabelPosition = UDim2.fromOffset(49, 34),
        LabelSize = UDim2.fromOffset(130, 37),
    })
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    SwitchTab: (tabName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Bookmarks) & ModuleData

return Bookmarks :: Module
