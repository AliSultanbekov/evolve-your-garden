--[=[
    @class ToolbarNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local ToolbarTypesShared = require("ToolbarTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        EquipSlot: Signal.Signal<Player, ToolbarTypesShared.EquipSlotRemotePacket>,
        UnequipSlot: Signal.Signal<Player>,
        BindSlots: Signal.Signal<Player, ToolbarTypesShared.BindSlotsRemotePacket>,
        UnbindSlots: Signal.Signal<Player, ToolbarTypesShared.UnbindSlotsRemotePacket>,
    },
    RemoteFunctions: {
        GetSlots: (player: Player) -> ToolbarTypesShared.GetSlotsRemotePacket
    }
}

export type Module = typeof(ToolbarNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolbarNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        EquipSlot = Signal.new(),
        UnequipSlot = Signal.new(),
        BindSlots = Signal.new(),
        UnbindSlots = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function ToolbarNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Toolbar")

    Channel:DeclareMethod("GetSlots")
    Channel:DeclareEvent("EquipSlot")
    Channel:DeclareEvent("UnequipSlot")
    Channel:DeclareEvent("BindSlots")
    Channel:DeclareEvent("UnbindSlots")

    Channel:Bind("GetSlots", function(player: Player)
        return self.RemoteFunctions.GetSlots(player)
    end)

    Channel:Connect("EquipSlot", function(player: Player, packet: ToolbarTypesShared.EquipSlotRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.SlotId) ~= "string" then
            return
        end

        self.RemoteEvents.EquipSlot:Fire(player, packet)
    end)

    Channel:Connect("UnequipSlot", function(player: Player)
        self.RemoteEvents.UnequipSlot:Fire(player)
    end)

    Channel:Connect("BindSlots", function(player: Player, packet: ToolbarTypesShared.BindSlotsRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.Slots) ~= "table" then
            return
        end

        for slotId, itemId in packet.Slots do
            if typeof(slotId) ~= "string" or typeof(itemId) ~= "string" then
                return
            end
        end

        self.RemoteEvents.BindSlots:Fire(player, packet)
    end)

    Channel:Connect("UnbindSlots", function(player: Player, packet: ToolbarTypesShared.UnbindSlotsRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.SlotIds) ~= "table" then
            return
        end

        for _, slotId in packet.SlotIds do
            if typeof(slotId) ~= "string" then
                return
            end
        end

        self.RemoteEvents.UnbindSlots:Fire(player, packet)
    end)
end

return ToolbarNetworkServer :: Module
