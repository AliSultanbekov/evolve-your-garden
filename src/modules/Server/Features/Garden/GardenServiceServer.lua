
--[=[
    @class GardenServiceServer
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local RxPlayerUtils = require("RxPlayerUtils")
local GardenConfig = require("GardenConfig")
local Brio = require("Brio")
local GardenTypesShared = require("GardenTypesShared")
local PlayerToUserId = require("PlayerToUserId")
local ItemTypes = require("ItemTypes")
local PlantUtil = require("PlantUtil")
local ItemUtil = require("ItemUtil")
local Maid = require("Maid")
local PlantsConfig = require("PlantsConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenNetworkServer: typeof(require("GardenNetworkServer")),
    _UpgradesServiceServer: typeof(require("UpgradesServiceServer")),
    _DataServiceServer: typeof(require("DataServiceServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _Maid: Maid.Maid,
    _GardenIdToUserId: {
        [GardenTypesShared.GardenId]: string,
    },
    _UserIdToGardenId: {
        [string]: GardenTypesShared.GardenId
    }
}

export type Module = typeof(GardenServiceServer) & ModuleData

-- [ Private Functions ] --
function GardenServiceServer._GetFreeGardenId(self: Module): GardenTypesShared.GardenId?
    local freeGardenId

    for i = 1, GardenConfig.MaxGardens do
        local gardenId = tostring(i)

        if self._GardenIdToUserId[gardenId] then
            continue
        end

        freeGardenId = gardenId
        break
    end

    return freeGardenId
end

function GardenServiceServer._GetUserGardenId(self: Module, userId: string): GardenTypesShared.GardenId?
    return self._UserIdToGardenId[userId]
end

function GardenServiceServer._GetGardenUpgrade(self: Module, player: Player): number
    return self._UpgradesServiceServer:GetUpgradeLevel(player, "Garden")
end

function GardenServiceServer._CreateAllSlots(self: Module, player: Player)
    local GardenUpgrade = self:_GetGardenUpgrade(player)
    local data = self._DataServiceServer:GetProfile(player).Data

    for i = 1, GardenConfig.UpgradeStats[GardenUpgrade].Slots do
        local SlotId = tostring(i)

        if not data.Garden.Slots[SlotId] then
            data.Garden.Slots[SlotId] = {
                Id = SlotId,
                Plant = nil,
                Harvest = {},
                HarvestCount = 0,
            }
        end
    end
end

-- [ Public Functions ] --
function GardenServiceServer.GrowthCycle(self: Module, dt: number)
    local Packet = {}

    for _, player in Players:GetChildren() do
        local UserId = PlayerToUserId(player)
        
        local GardenId = self._UserIdToGardenId[UserId]

        if not GardenId then
            continue
        end

        local Data = self._DataServiceServer:GetProfile(player).Data
        local GardenLevel = self._UpgradesServiceServer:GetUpgradeLevel(player, "Garden")
        local UpgradeStats = GardenConfig.UpgradeStats[GardenLevel]
        local HarvestCap = UpgradeStats.HarvestCap

        Packet[GardenId] = {}
    
        for _, slotData: GardenTypesShared.Slot in Data.Garden.Slots do
            local Plant = slotData.Plant

            if not Plant then
                continue
            end

            PlantUtil:AdvanceGrowth(Plant, dt)
            PlantUtil:RollMutation(Plant)

            Packet[GardenId][slotData.Id] = Plant
            
            if not PlantsConfig:IsPlantAdult(Plant.Name, Plant.GrowthTime) then
                continue
            end
    
            local HarvestDelta = HarvestCap - slotData.HarvestCount
    
            if HarvestDelta <= 0 then
                continue
            end

            local RawHarvestItems: { ItemTypes.RawItem } = {}

            local Cycles = PlantUtil:ClaimProductionCycles(Plant)

            if Cycles > 0 then
                PlantUtil:AddXp(Plant, Cycles)
            end

            local SafeCycles = math.min(Cycles, HarvestDelta)
    
            for _ = 1, SafeCycles do
                local CycleRawItems = PlantUtil:Produce(Plant)
                table.move(CycleRawItems, 1, #CycleRawItems, #RawHarvestItems + 1, RawHarvestItems)
            end
    
            self:AddRawHarvestItems(player, slotData.Id, RawHarvestItems)
        end
    end

    if next(Packet) then
        self._GardenNetworkServer:GrowthCycle({
            Growth = Packet
        })
    end
end

function GardenServiceServer.AddRawHarvestItems(self: Module, player: Player, slotId: GardenTypesShared.SlotId, rawItems: { ItemTypes.RawItem })
    local Items: { ItemTypes.Item } = {}

    for _, rawItem in rawItems do
        table.insert(Items, ItemUtil:ProcessRawItem(rawItem))
    end

    self:AddHarvestItems(player, slotId, Items)
end

function GardenServiceServer.AddHarvestItems(self: Module, player: Player, slotId: GardenTypesShared.SlotId, items: { ItemTypes.Item })
    local AddedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    local Data = self._DataServiceServer:GetProfile(player).Data
    local SlotData = Data.Garden.Slots[slotId]

    for _, item in items do
        ItemUtil:OnStorageMode(item, {
            ["Unique"] = function(item: ItemTypes.UniqueItem)
                SlotData.Harvest[item.Id] = item
                SlotData.HarvestCount += 1
                AddedItems[item.Id] = item
            end,
            ["Stackable"] = function(item: ItemTypes.StackableItem)
                local StoredItem = SlotData.Harvest[item.Id] :: ItemTypes.StackableItem

                if StoredItem then
                    StoredItem.Amount += item.Amount

                    if not AddedItems[item.Id] then
                        UpdatedItems[item.Id] = StoredItem
                    end
                else
                    SlotData.Harvest[item.Id] = item
                    SlotData.HarvestCount += 1
                    AddedItems[item.Id] = item
                end
            end,
        })
    end

    if next(AddedItems) then
        self._GardenNetworkServer:HarvestItemsAdded(player, { Items = AddedItems })
    end

    if next(UpdatedItems) then
        self._GardenNetworkServer:HarvestItemsUpdated(player, { Items = UpdatedItems })
    end
end

function GardenServiceServer.CollectHarvest(self: Module, player: Player, slotId: GardenTypesShared.SlotId)
    local UserId = PlayerToUserId(player)
    local GardenId = self:_GetUserGardenId(UserId)
    local Data = self._DataServiceServer:GetProfile(player).Data
    local SlotData = Data.Garden.Slots[slotId]

    if not GardenId then
        return
    end

    self._InventoryServiceServer:AddItems(player, SlotData.Harvest)
    SlotData.Harvest = {}
    SlotData.HarvestCount = 0

    self._GardenNetworkServer:HarvestCollected({
        GardenId = GardenId,
        SlotId = slotId
    })
end

function GardenServiceServer.PlacePlant(self: Module, player: Player, slotId: GardenTypesShared.SlotId, itemId: ItemTypes.ItemId)
    local data = self._DataServiceServer:GetProfile(player).Data
    local SlotData = data.Garden.Slots[slotId]
    local UserId = PlayerToUserId(player)
    local GardenId = self:_GetUserGardenId(UserId)

    if not GardenId then
        return
    end

    if SlotData.Plant then
        return
    end

    local Plant = self._InventoryServiceServer:GetItem(player, itemId)

    if not Plant then
        return
    end

    if Plant.Category ~= "Plant" then
        return
    end

    self._InventoryServiceServer:RemoveItems(player, { Plant })

    SlotData.Plant = Plant

    self._GardenNetworkServer:PlantPlaced({
        GardenId = GardenId,
        SlotId = slotId,
        Plant = Plant
    })
end

function GardenServiceServer.RemovePlant(self: Module, player: Player, slotId: GardenTypesShared.SlotId)
    local data = self._DataServiceServer:GetProfile(player).Data
    local SlotData = data.Garden.Slots[slotId]
    local UserId = PlayerToUserId(player)
    local GardenId = self:_GetUserGardenId(UserId)

    if not GardenId then
        return
    end

    if not SlotData.Plant then
        return
    end

    self._InventoryServiceServer:AddItems(player, { SlotData.Plant })

    SlotData.Plant = nil

    self._GardenNetworkServer:PlantRemoved({
        GardenId = GardenId,
        SlotId = slotId
    })
end

function GardenServiceServer.ClaimGarden(self: Module, player: Player)
    local UserId = PlayerToUserId(player)

    if self:_GetUserGardenId(UserId) then
        return
    end

    local freeGardenId = self:_GetFreeGardenId()

    if not freeGardenId then
        return
    end

    local GardenLevel = self._UpgradesServiceServer:GetUpgradeLevel(player, "Garden")

    if not GardenLevel then
        return
    end

    local Data = self._DataServiceServer:GetData(player)
    local Slots = Data.Garden.Slots

    self._UserIdToGardenId[UserId] = freeGardenId
    self._GardenIdToUserId[freeGardenId] = UserId

    self._GardenNetworkServer:GardenClaimed({
        GardenId = freeGardenId,
        UserId = UserId,
        GardenLevel = GardenLevel,
        Slots = Slots
    })
end

function GardenServiceServer.AbandonGarden(self: Module, player: Player)
    local UserId = PlayerToUserId(player)
    local GardenId = self:_GetUserGardenId(UserId)

    if not GardenId then
        return
    end

    self._UserIdToGardenId[UserId] = nil
    self._GardenIdToUserId[GardenId] = nil

    self._GardenNetworkServer:GardenAbandoned({
        GardenId = GardenId
    })
end

function GardenServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenNetworkServer = self._ServiceBag:GetService(require("GardenNetworkServer"))
    self._UpgradesServiceServer = self._ServiceBag:GetService(require("UpgradesServiceServer"))
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._Maid = Maid.new()
    self._GardenIdToUserId = {}
    self._UserIdToGardenId = {}
end

function GardenServiceServer.Start(self: Module)
    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()

        self:_CreateAllSlots(Player)

        self:ClaimGarden(Player)

        Maid:Add(function()
            self:AbandonGarden(Player)
        end)
    end)

    local Accum = 0

    self._Maid:Add(RunService.Heartbeat:Connect(function(dt: number)
        if Accum < GardenConfig.BaseTick then
            Accum += dt
            return
        end

        local TickDt = Accum
        Accum = 0

        self:GrowthCycle(TickDt)
    end))

    self._GardenNetworkServer.RemoteEvents.PlacePlant:Connect(function(player: Player, packet: GardenTypesShared.PlacePlantRemotePacket)
        self:PlacePlant(player, packet.SlotId, packet.ItemId)
    end)

    self._GardenNetworkServer.RemoteEvents.RemovePlant:Connect(function(player: Player, packet: GardenTypesShared.RemovePlantRemotePacket)
        self:RemovePlant(player, packet.SlotId)
    end)

    self._GardenNetworkServer.RemoteFunctions["GetGardens"] = function()
        local Gardens = {}

        for _, player in Players:GetPlayers() do
            local PlayerData = self._DataServiceServer:GetData(player)

            local UserId = PlayerToUserId(player)
            local GardenId = self:_GetUserGardenId(UserId)
            local GardenLevel = self._UpgradesServiceServer:GetUpgradeLevel(player, "Garden")
            local Slots = PlayerData.Garden.Slots

            if not GardenId then
                continue
            end

            Gardens[GardenId] = {
                Id = GardenId,
                Owner = UserId,
                Level = GardenLevel,
                Slots = Slots,
            }
        end

        return { Gardens = Gardens }
    end
end

return GardenServiceServer :: Module
