--[=[
    @class InventoryUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")

local WindowComponent = require(script.Parent.Components.InventoryWindow._WindowComponent)
local InventoryConfig = require(script.Parent.Parent._InventoryConfig)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>
}

export type Module = typeof(InventoryUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InventoryUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Garden")
end

function InventoryUIClient.Start(self: Module)
    self._UIServiceClient:RegisterUI({
        UIName = "Inventory",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })

    local IsOpen = self._UIServiceClient:ObserveUI("Inventory")
    local Items = self._InventoryServiceClient:GetItems()
    local TabsConfig = InventoryConfig.TabsConfig

    self._Maid:Add(Blend.mount(self._UIServiceClient:GetScreen("Main"), {
        WindowComponent({
            -- Vars
            IsOpen = IsOpen,

            Items = Items,
            TabsConfig = TabsConfig,
            ActiveTab = self._ActiveTab:Observe(),

            OnTabSwitched = function(tabName: string)
                if tabName == self._ActiveTab.Value then
                    return
                end

                self._ActiveTab.Value = tabName
            end,
            -- Functions
            OnClose = function()
                self._UIServiceClient:CloseUI("Inventory")
            end,
        })
    }))
end

return InventoryUIClient :: Module