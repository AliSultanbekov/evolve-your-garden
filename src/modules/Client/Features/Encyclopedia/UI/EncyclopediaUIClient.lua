--[=[
    @class EncyclopediaUIClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")

-- [ Components ] --
local EncyclopediaComponent = require(script.Parent.Components.EncyclopediaComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EncyclopediaUIClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EncyclopediaServiceClient: typeof(require("EncyclopediaServiceClient")),
    _UIServiceClient: typeof(require("UIServiceClient")),
    _Maid: Maid.Maid,
    _ActiveTab: ValueObject.ValueObject<string>,
    _Search: ValueObject.ValueObject<string>,
}

export type Module = typeof(EncyclopediaUIClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EncyclopediaUIClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EncyclopediaServiceClient = self._ServiceBag:GetService(require("EncyclopediaServiceClient"))
    self._UIServiceClient = self._ServiceBag:GetService(require("UIServiceClient"))
    self._Maid = Maid.new()
    self._ActiveTab = ValueObject.new("Plants")
    self._Search = ValueObject.new("")

    self._UIServiceClient:RegisterUI({
        UIName = "Encyclopedia",
        Category = "Main",
        Conflicts = {
            ["Main"] = true
        },
    })
end

function EncyclopediaUIClient.Start(self: Module)
    self._Maid:Add(self._UIServiceClient:MountToScreen("UIs", function(a0: ScreenGui): {any} return {
        EncyclopediaComponent({
            IsOpen = self._UIServiceClient:ObserveUI("Encyclopedia"),
            ActiveTab = self._ActiveTab:Observe(),
            ClaimableCount = ValueObject.new(0):Observe(),
            DiscoveredPlantsCount = self._EncyclopediaServiceClient:ObserveDiscoveredPlantsCount(),
            OnClose = function()
                
            end,
            OnSearch = function(text: string)
                self._Search.Value = text
            end,
            SwitchTab = function(tabName: string)
                self._ActiveTab.Value = tabName
            end,
            GetDiscoveredItem = function(itemName: string)
                return self._EncyclopediaServiceClient:GetDiscoveredItem(itemName)
            end
        })
    } end))
end

return EncyclopediaUIClient :: Module