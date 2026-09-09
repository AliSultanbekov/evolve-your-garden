--[=[
    @class Bookmarks
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local ComponentTypes = require("ComponentTypes")
local InventoryConfigClient = require("InventoryConfigClient")

-- [ Components ] --
local BookmarksComponent = require("BookmarksComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Bookmarks = function(props: Props)
    local Tabs: { BookmarksComponent.Tab } = {}

    for _, tabName in InventoryConfigClient.TabOrder do
        table.insert(Tabs, { Name = tabName })
    end

    return BookmarksComponent({
        ActiveTab = props.ActiveTab,
        SwitchTab = props.SwitchTab,
        Tabs = Tabs,

        Image = "rbxassetid://115398131882506",
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
