--[=[
    @class PackStoreWorldClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Components ] --
local _Pack = require(script.Parent._Pack) -- world pack display, not yet mounted

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
}

export type Module = typeof(PackStoreWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PackStoreWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function PackStoreWorldClient.Start(self: Module)
    -- TODO: mount world pack displays (_Pack) from the current sale.
    -- NOTE for that work: _Pack uses a fixed BindToRenderStep name ("PackAnim")
    -- — per-instance components need unique binding names or one Heartbeat
    -- connection driving all of them.
end

return PackStoreWorldClient :: Module