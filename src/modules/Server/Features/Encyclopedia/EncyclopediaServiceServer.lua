--[=[
    @class EncyclopediaServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ItemUtil = require("ItemUtil")
local Signal = require("Signal")
local EncyclopediaTypesShared = require("EncyclopediaTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EncyclopediaServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    _StatsServiceServer: typeof(require("StatsServiceServer")),
    _EncyclopediaNetworkServer: typeof(require("EncyclopediaNetworkServer")),
    Signals: {
        ItemDiscovered: Signal.Signal<Player, string, number, number>
    }
}

export type Module = typeof(EncyclopediaServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EncyclopediaServiceServer.GetDiscoveredItems(self: Module, player: Player): { [string]: EncyclopediaTypesShared.DiscoveredItem }
    local PlayerData = self._DataServiceServer:GetData(player)

    return PlayerData.Encyclopedia.DiscoveredItems
end

function EncyclopediaServiceServer.GetTotalAcquired(self: Module, player: Player, itemName: string)
    local PlayerData = self._DataServiceServer:GetData(player)
    local EncyclopediaData = PlayerData.Encyclopedia
    
    local ItemAcquiredInfo = EncyclopediaData.DiscoveredItems[itemName]

    -- Not-yet-discovered is a normal state (quest checks query arbitrary
    -- items) — it means zero acquired, not an error.
    if not ItemAcquiredInfo then
        return 0
    end

    return ItemAcquiredInfo.TotalAcquired
end

function EncyclopediaServiceServer.DiscoverItems(self: Module, player: Player, items: { [any]: ItemTypes.Item })
    local PlayerData = self._DataServiceServer:GetData(player)
    local EncyclopediaData = PlayerData.Encyclopedia
    local DiscoveredItemNames = {}

    for _, item in items do
        if item.Category == "Currency" then
            continue
        end

        local DiscoveredItemData = EncyclopediaData.DiscoveredItems[item.Name]
        
        if not DiscoveredItemData then
            DiscoveredItemData = {
                DiscoveredTime = DateTime.now().UnixTimestamp,
                TotalAcquired = 0
            }
        end

        ItemUtil:OnStorageMode(item, {
            ["Stackable"] = function(item: ItemTypes.StackableItem)
                DiscoveredItemData.TotalAcquired += item.Amount
            end,
            ["Unique"] = function(item: ItemTypes.UniqueItem)
                DiscoveredItemData.TotalAcquired += 1
            end
        })

        EncyclopediaData.DiscoveredItems[item.Name] = DiscoveredItemData

        DiscoveredItemNames[item.Name] = true
    end

    for itemName, _ in DiscoveredItemNames do
        local DiscoveredItemData = EncyclopediaData.DiscoveredItems[itemName]


        self.Signals.ItemDiscovered:Fire(player, itemName, DiscoveredItemData.TotalAcquired, DiscoveredItemData.DiscoveredTime)
    end
end

function EncyclopediaServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._EncyclopediaNetworkServer = self._ServiceBag:GetService(require("EncyclopediaNetworkServer"))
    self.Signals = {
        ItemDiscovered = Signal.new()
    } :: any
end

function EncyclopediaServiceServer.Start(self: Module)
    self._EncyclopediaNetworkServer.RemoteFunctions.GetDiscoveredItems = function(player: Player): EncyclopediaTypesShared.GetDiscoveredItemsRemotePacket
        return {
            DiscoveredItems = self:GetDiscoveredItems(player)
        }
    end
end

return EncyclopediaServiceServer :: Module