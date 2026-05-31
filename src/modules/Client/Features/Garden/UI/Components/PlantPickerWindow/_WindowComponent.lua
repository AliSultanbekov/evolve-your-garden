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
local CloseButtonComponent = require("CloseButtonComponent")
local ItemsGridComponent = require("ItemsGridComponent")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WindowComponent = function(props: Props)
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    Items: InventoryTypesClient.Items,
    OnClose: () -> (),
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem) -> ()
}
type ModuleData = {}

export type Module = typeof(WindowComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return WindowComponent :: Module