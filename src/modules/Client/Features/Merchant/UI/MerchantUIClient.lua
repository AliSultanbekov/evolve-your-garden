--[=[
    @class MerchantUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")

-- [ Components ] --
local Merchant = require(script.Parent.Components._Merchant)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIServiceClient: typeof(require("UIServiceClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _MerchantServiceClient: typeof(require("MerchantServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>,
    _Search: ValueObject.ValueObject<string>,
}

export type Module = typeof(MerchantUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._MerchantServiceClient = self._ServiceBag:GetService(require("MerchantServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Sell")
    self._Search = ValueObject.new("")

    self._UIServiceClient:RegisterUI({
        UIName = "Merchant",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        }
    })
end

function MerchantUIClient.Start(self: Module)
    self._UIServiceClient:OpenUI("Merchant")

    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function() return {
        Merchant({
            IsOpen = self._UIServiceClient:ObserveUI("Merchant"),
            ActiveTab = self._ActiveTab:Observe(),
            Items = self._InventoryServiceClient:GetItemsByCategory("Material"),
            Search = self._Search:Observe(),
            BuySlots = self._MerchantServiceClient:GetBuySlots(),
            LastRefresh = self._MerchantServiceClient:ObserveLastRefresh(),

            SwitchTab = function(tab: string)
                self._ActiveTab.Value = tab
            end,
            Buy = function(slotId: string)
                self._MerchantServiceClient:Buy(slotId)
            end,
            Sell = function(itemId: string, amount: number)
                self._MerchantServiceClient:Sell(itemId, amount)
            end,
            OnSearch = function(text: string)
                self._Search.Value = text
            end,
            OnClose = function()
                self._UIServiceClient:CloseUI("Merchant")
            end
        })
    } end))
end

return MerchantUIClient :: Module