--[=[
    @class WindowComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local GardenTypesClient = require("GardenTypesClient")
local UIConfig = require("UIConfig")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local GenericTextComponent = require("GenericTextComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local WindowComponent = function(props: Props)
    
end

-- [ Types ] --
type Props = {
    Adornee: Observable.Observable<GardenTypesClient.SlotModel?>,
    IsOpen: Observable.Observable<boolean>,
}
type ModuleData = {}

export type Module = typeof(WindowComponent) & ModuleData

return WindowComponent :: Module
