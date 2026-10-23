--[=[
    @class ToolbarConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ToolbarTypesShared = require("ToolbarTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarConfig = {}

-- [ Private Functions ] --
function ToolbarConfig._Init(self: Module)
    self.SlotOrder = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
    self.SlotCount = #self.SlotOrder
    self.SlotIds = {}
    self.KeyCodeToSlotId = {
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
    }

    for _, slotId in self.SlotOrder do
        self.SlotIds[slotId] = true
    end
end

-- [ Public Functions ] --
function ToolbarConfig.IsValidSlotId(self: Module, slotId: string): boolean
    return self.SlotIds[slotId] == true
end

-- [ Types ] --
type ModuleData = {
    SlotOrder: { ToolbarTypesShared.SlotId },
    SlotCount: number,
    SlotIds: { [ToolbarTypesShared.SlotId]: boolean },
    KeyCodeToSlotId: { [Enum.KeyCode]: ToolbarTypesShared.SlotId },
}

export type Module = typeof(ToolbarConfig) & ModuleData

(ToolbarConfig :: any):_Init()

return ToolbarConfig :: Module
