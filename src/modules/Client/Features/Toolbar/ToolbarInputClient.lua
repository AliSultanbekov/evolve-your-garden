
--[=[
    @class ToolbarInputClient
]=]

-- [ Roblox Services ] --
local UserInputService = game:GetService("UserInputService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ToolbarConfig = require("ToolbarConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarInputClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(ToolbarInputClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolbarInputClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarServiceClient = self._ServiceBag:GetService(require("ToolbarServiceClient"))
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()
end

function ToolbarInputClient.Start(self: Module)
    self._Maid:Add(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed then
            return
        end

        if self._UIServiceClient:GetUIState("Inventory") then
            return
        end

        local Slot = ToolbarConfig.KeyCodeToSlotId[input.KeyCode]

        if not Slot then
            return
        end

        self._ToolbarServiceClient:EquipSlot(Slot)
    end))
end

return ToolbarInputClient :: Module