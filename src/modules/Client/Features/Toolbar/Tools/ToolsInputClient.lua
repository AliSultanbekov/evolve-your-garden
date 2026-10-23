
--[=[
    @class ToolsInputClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local UserInputService = game:GetService("UserInputService")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsInputClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolServiceClient: typeof(require("ToolServiceClient")),
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(ToolsInputClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolsInputClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolServiceClient = self._ServiceBag:GetService(require("ToolServiceClient"))
    self._ToolbarServiceClient = self._ServiceBag:GetService(require("ToolbarServiceClient"))
    self._Maid = Maid.new()
end

function ToolsInputClient.Start(self: Module)
    self._Maid:Add(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        self._ToolServiceClient:ActivateTool()
    end))
end

return ToolsInputClient :: Module