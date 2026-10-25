
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
local PlantUtilShared = require("PlantUtilShared")
local PlantUtilServer = require("PlantUtilServer")
local ItemUtil = require("ItemUtil")
local Maid = require("Maid")
local ItemConfig = require("ItemConfig")
local GeneralTypesShared = require("GeneralTypesShared")
local ReconcileUtil = require("ReconcileUtil")
local GeneralEnums = require("GeneralEnums")
local Table = require("Table")
local GardenUtil = require("GardenUtil")

-- [ Constants ] --
local GARDEN_TEMPLATE = {
    Slots = {},
}

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
    },
    _UserIdToSlotIdToHarvestFill: {
        [string]: {
            [GardenTypesShared.SlotId]: number
        }
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

function GardenServiceServer._CanAccessGarden(self: Module, player: Player, gardenId: GardenTypesShared.GardenId): boolean
    return self._GardenIdToUserId[gardenId] == PlayerToUserId(player)
end

function GardenServiceServer._CreateAllSlots(self: Module, player: Player)
    local GardenLevel = self._UpgradesServiceServer:GetUpgradeLevel(player, "Garden")
    local Data = self._DataServiceServer:GetProfile(player).Data
    local UpgradeStats = GardenConfig:GetUpgradeStats(GardenLevel)
    local UserId = PlayerToUserId(player)
    local SlotIdToHarvestFill = self._UserIdToSlotIdToHarvestFill[UserId]
    
    for i = 1, UpgradeStats.Slots do
        local SlotId = tostring(i)
        local Slot = Data.Garden.Slots[SlotId]

        if not Slot then
            Data.Garden.Slots[SlotId] = {
                Id = SlotId,
                Plant = nil,
                Harvest = {},
            }
        end

        SlotIdToHarvestFill[SlotId] = Table.count(Slot.Harvest)
    end
end

-- [ Public Functions ] --
function GardenServiceServer.CollectHarvest(self: Module, player: Player, gardenId: GardenTypesShared.GardenId, slotId: GardenTypesShared.SlotId): GeneralTypesShared.DefaultResult
    if not self:_CanAccessGarden(player, gardenId) then
        return GeneralEnums.Result.Fail
    end

    local Data = self._DataServiceServer:GetProfile(player).Data
    local UserId = PlayerToUserId(player)
    local SlotIdToHarvestFill = self._UserIdToSlotIdToHarvestFill[UserId]

    local SlotData = Data.Garden.Slots[slotId]

    if not SlotData then
        return GeneralEnums.Result.Fail
    end

    local Harvest = SlotData.Harvest

    local Result: GeneralTypesShared.DefaultResult = self._InventoryServiceServer:AddItems(player, Harvest)

    if Result == GeneralEnums.Result.Fail then
        return GeneralEnums.Result.Fail
    end

    SlotData.Harvest = {}
    SlotIdToHarvestFill[slotId] = 0

    self._GardenNetworkServer:HarvestCollected({
        GardenId = gardenId,
        SlotId = slotId
    })

    return GeneralEnums.Result.Success
end

function GardenServiceServer.GrowthCycle(self: Module, elapsed: number)
    self:AdvanceGrowth(Players:GetPlayers(), elapsed)
end

function GardenServiceServer.AdvanceGrowth(self: Module, players: { Player }, elapsed: number)
    for _, player in players do
        local PlayerData = self._DataServiceServer:GetData(player)
        local UserId = PlayerToUserId(player)
        local GardenData = PlayerData.Garden
        local SlotsData = GardenData.Slots
        local GardenId = self:_GetUserGardenId(UserId)

        if not GardenId then
            continue
        end

        local Plants = {}
        local Harvests = {}
    
        for slotId, slotData in SlotsData do
            local Plant = slotData.Plant
    
            if not Plant then
                continue
            end
    
            PlantUtilServer:AdvanceGrowth(Plant, elapsed)
            Plants[slotId] = Plant

            if not PlantUtilShared:IsPlantFullyGrown(Plant.Name, Plant.GrowthTime) then
                continue
            end

            local ProductionCycles = PlantUtilServer:ClaimProductionCycles(Plant)
            local NewHarvest = {}

            for i = 1, ProductionCycles do
                local Harvest = PlantUtilServer:Produce(Plant)

                table.move(Harvest, 1, #Harvest, #NewHarvest + 1, NewHarvest)
            end

            if #NewHarvest == 0 then
                continue
            end

            Harvests[slotId] = NewHarvest
        end

        if next(Harvests) ~= nil then
            self:AddHarvestItems(player, GardenId, Harvests)
        end
    end
end

--[[function GardenServiceServer.GrowthCycle(self: Module, dt: number)
    local Packet = {}

    for _, player in Players:GetChildren() do
        local UserId = PlayerToUserId(player)
        
        local GardenId = self._UserIdToGardenId[UserId]

        if not GardenId then
            continue
        end

        local Data = self._DataServiceServer:GetProfile(player).Data
        local HarvestCap = GardenConfig.HarvestCap

        Packet[GardenId] = {}

        local Harvest = {}
    
        for _, slotData: GardenTypesShared.Slot in Data.Garden.Slots do
            local Plant = slotData.Plant

            if not Plant then
                continue
            end

            PlantUtil:AdvanceGrowth(Plant, dt)
            PlantUtil:RollMutation(Plant)

            Packet[GardenId][slotData.Id] = Plant
            
            if not PlantUtil:IsPlantFullyGrown(Plant.Name, Plant.GrowthTime) then
                continue
            end
    
            local HarvestDelta = HarvestCap - slotData.HarvestCount
    
            if HarvestDelta <= 0 then
                continue
            end

            local Cycles = PlantUtil:ClaimProductionCycles(Plant)

            if Cycles <= 0 then
                continue
            end

            if not Harvest[slotData.Id] then
                Harvest[slotData.Id] = {}
            end

            PlantUtil:AddXp(Plant, Cycles)

            local SafeCycles = math.min(Cycles, HarvestDelta)
    
            for _ = 1, SafeCycles do
                local CycleItems = PlantUtil:Produce(Plant)
                table.move(CycleItems, 1, #CycleItems, #Harvest[slotData.Id] + 1, Harvest[slotData.Id])
            end
        end

        self:AddHarvestItems(player, Harvest)
    end

    if next(Packet) then
        self._GardenNetworkServer:GrowthCycle({
            Growth = Packet
        })
    end
end]]

function GardenServiceServer.AddHarvestItems(self: Module, player: Player, gardenId: GardenTypesShared.GardenId, harvests: { [GardenTypesShared.SlotId]: { [any]: ItemTypes.Item } }): GeneralTypesShared.DefaultResult
    if not self:_CanAccessGarden(player, gardenId) then
        return GeneralEnums.Result.Fail
    end

    local AddedItemsHarvest: { [GardenTypesShared.SlotId]: GardenTypesShared.HarvestSlotChanges } = {}
    local UpdatedItemsHarvest: { [GardenTypesShared.SlotId]: GardenTypesShared.HarvestSlotChanges } = {}

    local Data = self._DataServiceServer:GetProfile(player).Data
    local HarvestCap = GardenConfig.HarvestCap
    local UserId = PlayerToUserId(player)
    local SlotIdToHarvestFill = self._UserIdToSlotIdToHarvestFill[UserId]
    local SlotIdToPredictedHarvestFill = {}

    -- space check
    for slotId, items in harvests do
        local PredictedHarvestFill = SlotIdToHarvestFill[slotId]
        local Harvest = {}

        for _, item in items do
            ItemUtil:OnStorageMode(item, {
                ["All"] = function(item: ItemTypes.Item)
                    if Harvest[item.Id] then
                        return
                    end

                    Harvest[item.Id] = item

                    if not Data.Garden.Slots[slotId].Harvest[item.Id] then
                        PredictedHarvestFill += 1
                    end
                end,
                ["Stackable"] = function(item: ItemTypes.StackableItem)
                    local ExistingItem = Harvest[item.Id] :: ItemTypes.StackableItem

                    if not ExistingItem then
                        return
                    end

                    if ExistingItem == item then
                        return
                    end

                    if ExistingItem.Amount > ItemConfig.MaxAmount then
                        return
                    end

                    (ExistingItem :: ItemTypes.Stackable).Amount = math.clamp(ExistingItem.Amount + item.Amount, 0, ItemConfig.MaxAmount)
                end
            })
        end

        SlotIdToPredictedHarvestFill[slotId] = PredictedHarvestFill
        harvests[slotId] = Harvest

        if PredictedHarvestFill > HarvestCap then
            return GeneralEnums.Result.Fail
        end
    end

    -- add to harvest
    for slotId, items in harvests do
        local SlotData = Data.Garden.Slots[slotId]
        local HarvestData: { [ItemTypes.ItemId]: ItemTypes.Item} = SlotData.Harvest

        for _, item in items do
            ItemUtil:OnStorageMode(item, {
                ["All"] = function(item: ItemTypes.Item)
                    if HarvestData[item.Id] then
                        return
                    end

                    HarvestData[item.Id] = item

                    if not AddedItemsHarvest[slotId] then
                        AddedItemsHarvest[slotId] = { Harvest = {}, Item = SlotData.Plant }
                    end

                    AddedItemsHarvest[slotId].Harvest[item.Id] = item
                end,
                ["Stackable"] = function(item: ItemTypes.StackableItem)
                    local IsRecentlyAdded = AddedItemsHarvest[slotId] and AddedItemsHarvest[slotId].Harvest[item.Id]
                    local ExistingItem = HarvestData[item.Id] :: ItemTypes.StackableItem

                    if IsRecentlyAdded then
                        return
                    end

                    if not ExistingItem then
                        return
                    end

                    (ExistingItem :: ItemTypes.Stackable).Amount = math.clamp(ExistingItem.Amount + item.Amount, 0, ItemConfig.MaxAmount)

                    if not UpdatedItemsHarvest[slotId] then
                        UpdatedItemsHarvest[slotId] = { Harvest = {}, Item = SlotData.Plant }
                    end

                    UpdatedItemsHarvest[slotId].Harvest[item.Id] = ExistingItem
                end
            })
        end

        SlotIdToHarvestFill[slotId] = SlotIdToPredictedHarvestFill[slotId]
    end

    if next(AddedItemsHarvest) then
        self._GardenNetworkServer:HarvestItemsAdded(player, { GardenId = gardenId, Harvest = AddedItemsHarvest })
    end

    if next(UpdatedItemsHarvest) then
        self._GardenNetworkServer:HarvestItemsUpdated(player, { GardenId = gardenId, Harvest = UpdatedItemsHarvest })
    end

    return GeneralEnums.Result.Success
end

function GardenServiceServer.PlacePlant(self: Module, player: Player, gardenId: GardenTypesShared.GardenId, slotId: GardenTypesShared.SlotId, itemId: ItemTypes.ItemId)
    if not self:_CanAccessGarden(player, gardenId) then
        return
    end

    local data = self._DataServiceServer:GetProfile(player).Data
    local SlotData = data.Garden.Slots[slotId]

    if not SlotData then
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
        GardenId = gardenId,
        SlotId = slotId,
        Plant = Plant
    })
end

function GardenServiceServer.RemovePlant(self: Module, player: Player, gardenId: GardenTypesShared.GardenId, slotId: GardenTypesShared.SlotId)
    if not self:_CanAccessGarden(player, gardenId) then
        return
    end

    local data = self._DataServiceServer:GetProfile(player).Data
    local SlotData = data.Garden.Slots[slotId]

    if not SlotData then
        return
    end

    if not SlotData.Plant then
        return
    end

    local Result_1 = self:CollectHarvest(player, gardenId, slotId)

    if Result_1 == GeneralEnums.Result.Fail then
        return
    end

    local Result_2 = self._InventoryServiceServer:AddItems(player, { SlotData.Plant })

    if Result_2 == GeneralEnums.Result.Fail then
        return
    end

    SlotData.Plant = nil

    self._GardenNetworkServer:PlantRemoved({
        GardenId = gardenId,
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
    self._UserIdToSlotIdToHarvestFill = {}
end

function GardenServiceServer.Start(self: Module)
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

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local PlayerMaid, Player = brio:ToMaidAndValue()
        local UserId = PlayerToUserId(Player)

        self._UserIdToSlotIdToHarvestFill[UserId] = {}

        PlayerMaid:Add(function()
            self._UserIdToSlotIdToHarvestFill[UserId] = nil
        end)

        PlayerMaid:Add(self._DataServiceServer:OnDataReady(Player, function(data)
            ReconcileUtil:Reconcile(data.Garden, GARDEN_TEMPLATE)
            
            self:_CreateAllSlots(Player)
            self:ClaimGarden(Player)

            return function()
                self:AbandonGarden(Player)
            end
        end))
    end)

    local Elapsed = 0

    self._Maid:Add(RunService.Heartbeat:Connect(function(dt: number)
        if not GardenUtil:TickCheck(Elapsed) then
            Elapsed += dt
            return
        end

        local ElapsedGrowth = Elapsed
        Elapsed = 0

        self:GrowthCycle(ElapsedGrowth)
    end))

    self._GardenNetworkServer.RemoteEvents.PlacePlant:Connect(function(player: Player, packet: GardenTypesShared.PlacePlantRemotePacket)
        self:PlacePlant(player, packet.GardenId, packet.SlotId, packet.ItemId)
    end)

    self._GardenNetworkServer.RemoteEvents.RemovePlant:Connect(function(player: Player, packet: GardenTypesShared.RemovePlantRemotePacket)
        self:RemovePlant(player, packet.GardenId, packet.SlotId)
    end)

    self._GardenNetworkServer.RemoteEvents.CollectHarvest:Connect(function(player: Player, packet: GardenTypesShared.CollectHarvestRemotePacket)
        self:CollectHarvest(player, packet.GardenId, packet.SlotId)
    end)
end

return GardenServiceServer :: Module
