--[=[
    @class ToolServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolServiceClient = {}

-- [ Types ] --
export type Signals = {
    ToolActivated: Signal.Signal<ItemTypes.ItemId>
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarServiceClient: typeof(require("ToolbarServiceClient")),
    _ToolsNetworkClient: typeof(require("ToolsNetworkClient")),
    Signals: Signals,
}

export type Module = typeof(ToolServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolServiceClient.ActivateTool(self: Module, params: { [string]: any }?)
    local EquippedItem = self._ToolbarServiceClient:GetEquippedItem()

    if not EquippedItem then
        return
    end

    self.Signals.ToolActivated:Fire(EquippedItem.Id)
    self._ToolsNetworkClient:ActivateTool({ Params = params })
end

function ToolServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarServiceClient = self._ServiceBag:GetService(require("ToolbarServiceClient"))
    self._ToolsNetworkClient = self._ServiceBag:GetService(require("ToolsNetworkClient"))
    self.Signals = {
        ToolActivated = Signal.new()
    } :: any
end

function ToolServiceClient.Start(self: Module)

end

return ToolServiceClient :: Module