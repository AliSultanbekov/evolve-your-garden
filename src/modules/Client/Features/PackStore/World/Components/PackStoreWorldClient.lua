--[=[
    @class PackStoreWorldClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Components ] --
local Pack = require(script.Parent._Pack)

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
    --[[task.delay(8, function()
        print("Sssss")
        Pack({
            PackName = "Super Pack",
            PackNumber = 1,
            TotalPacks = 4,
        })
        Pack({
            PackName = "Super Pack",
            PackNumber = 2,
            TotalPacks = 4,
        })
        Pack({
            PackName = "Super Pack",
            PackNumber = 3,
            TotalPacks = 4,
        })
        Pack({
            PackName = "Super Pack",
            PackNumber = 4,
            TotalPacks = 4,
        })
    end)]]
end

return PackStoreWorldClient :: Module