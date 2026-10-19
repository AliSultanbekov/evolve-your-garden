--[=[
    @class ToolbarConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
-- Slot ids mirror the keyboard row: "1".."9" then "0" for the tenth slot.
-- SlotOrder is the one truth (display + keybind order); the SlotIds set is
-- derived from it for O(1) validation.
local ToolbarConfig = {
    SlotCount = 10,
    SlotOrder = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    SlotIds = {},
}

for _, slotId in ToolbarConfig.SlotOrder do
    ToolbarConfig.SlotIds[slotId] = true
end

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ToolbarConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
-- Anything outside SlotIds is rejected at the server boundary so clients
-- can never grow Data.Toolbar past the real bar.
function ToolbarConfig.IsValidSlotId(self: Module, slotId: string): boolean
    return self.SlotIds[slotId] == true
end

return ToolbarConfig :: Module
