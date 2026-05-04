--[=[
    @class GardenServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
}

export type Module = typeof(GardenServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function GardenServiceClient.Start(self: Module)

end

return GardenServiceClient :: Module