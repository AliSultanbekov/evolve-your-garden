--[=[
    @class PackStoreUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local Maid = require("Maid")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Components ] --
local PackStoreWindow = require(script.Parent.Components.PackStore._Window)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _PackStoreServiceClient: typeof(require("PackStoreServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>,
}

export type Module = typeof(PackStoreUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PackStoreUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._PackStoreServiceClient = self._ServiceBag:GetService(require("PackStoreServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Normal")

    self._UIServiceClient:RegisterUI({
        UIName = "PackStore",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        }
    })
end

function PackStoreUIClient.Start(self: Module)
    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        PackStoreWindow({
            IsOpen = self._UIServiceClient:ObserveUI("PackStore"),
            Packs = self._PackStoreServiceClient:GetPacks(),
            ActiveTab = self._ActiveTab:Observe(),

            SwitchTab = function(tabName: string)
                self._ActiveTab.Value = tabName
            end,
            BuyPack = function(packId: PackStoreTypesShared.PackId)
                self._PackStoreServiceClient:BuyPack(packId)
            end
        })
    } end))
end

return PackStoreUIClient :: Module