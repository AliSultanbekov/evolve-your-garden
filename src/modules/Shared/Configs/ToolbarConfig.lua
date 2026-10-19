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
local ToolbarConfig = {
    SlotCount = 10,
    SlotIds = {
        ["1"] = true,
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true,
        ["6"] = true,
        ["7"] = true,
        ["8"] = true,
        ["9"] = true,
        ["0"] = true,
    },
}

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
