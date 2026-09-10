--[=[
    @class QuestsServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestsServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
}

export type Module = typeof(QuestsServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function QuestsServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function QuestsServiceClient.Start(self: Module)

end

return QuestsServiceClient :: Module