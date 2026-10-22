--[=[
    @class ToolsServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local Maid = require("Maid")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _Maid: Maid.Maid,
    _ItemIdToToolState: {
        [ItemTypes.ItemId]: {
            [any]: any
        }
    }
}

export type Module = typeof(ToolsServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolsServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._Maid = Maid.new()
    self._ItemIdToToolState = {}
end

function ToolsServiceClient.Start(self: Module)
    self._Maid:Add(self._InventoryServiceClient.Signals.ItemAdded:Connect(function(item: ReactiveItemTypes.ReactiveItem)
        --self._ItemIdToToolState[]
    end))
end

return ToolsServiceClient :: Module