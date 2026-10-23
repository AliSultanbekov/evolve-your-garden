--[=[
    @class ToolServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolServiceClient = {}

-- [ Types ] --
export type Signals = {
    ToolActivated: Signal.Signal<>
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    Signals: Signals
}

export type Module = typeof(ToolServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self.Signals = {
        ToolActivated = Signal.new()
    }
end

function ToolServiceClient.Start(self: Module)

end

return ToolServiceClient :: Module