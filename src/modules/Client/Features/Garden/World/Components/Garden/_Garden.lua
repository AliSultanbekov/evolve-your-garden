
--[=[
    @class Garden
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local GardenTypesClient = require("GardenTypesClient")
local GardenTypesShared = require("GardenTypesShared")
local Rx = require("Rx")
local AssetProvider = require("AssetProvider")
local GardenConfig = require("GardenConfig")
local Brio = require("Brio")

-- [ Components ] --
local SlotComponent = require(script.Parent._Slot)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Garden = function(props: Props)
    local MaidObject = Maid.new()
    local GardenMaid = MaidObject:Add(Maid.new())
    local Garden = props.Garden

    local function SetupGardenModel(model: GardenModel)
        model.Parent = workspace.World.Gardens[Garden.GardenId]
    end

    local function GetSlotCFrame(model: GardenModel, level: number, slot: number)
        local Stats = GardenConfig.UpgradeStats[level]
        local OriginCFrame = model.SlotsSpawnPoint.WorldCFrame
        local Slots = Stats.Slots
        local Spacing = Stats.Spacing
        local Cols = Stats.Cols
        local Rows = math.ceil(Slots / Cols)

        local OffsetX = -(Rows - 1) * Spacing / 2
        local OffsetZ = -(Cols - 1) * Spacing / 2

        local Row = (slot-1) % Rows
        local Col = math.floor((slot-1) / Rows)

        local Offset = Vector3.new(
            OffsetX + Row * Spacing,
            0,
            OffsetZ + Col * Spacing
        )

        local SlotCFrame = OriginCFrame * CFrame.new(Offset)

        return SlotCFrame
    end
    
    MaidObject:Add(Rx.combineLatest({
        Owner = Garden.Owner:Observe(),
        Level = Garden.Level:Observe(),
    }):Subscribe(function(state)
        GardenMaid:DoCleaning()
        
        if not state.Owner or not state.Level then
            return
        end

        local GardenModel = AssetProvider:Get(string.format("Objects/Garden/Upgrades/%s", tostring(state.Level))) :: GardenModel

        GardenMaid:Add(GardenModel)

        SetupGardenModel(GardenModel)

        GardenMaid:Add(Garden.Slots:ObservePairsBrio():Subscribe(function(brio: Brio.Brio<GardenTypesShared.SlotId, GardenTypesClient.ReactiveSlot>)
            if brio:IsDead() then 
                return 
            end

            local SlotMaid: Maid.Maid, SlotId: GardenTypesShared.SlotId, Slot: GardenTypesClient.ReactiveSlot = brio:ToMaidAndValue()

            local SlotNumber = tonumber(SlotId)

            if not SlotNumber then
                return
            end

            SlotMaid:Add(
                SlotComponent({
                    MouseServiceClient = props.MouseServiceClient,

                    Garden = Garden,
                    Slot = Slot,
                    SlotCFrame = GetSlotCFrame(GardenModel, state.Level, SlotNumber),

                    OnSlotSelected = props.OnSlotSelected
                })
            )
        end))
    end))

    return MaidObject
end

-- [ Types ] --
type GardenModel = typeof(ReplicatedStorage.Assets.Objects.Garden.Upgrades["1"])
type Props = {
    MouseServiceClient: typeof(require("MouseServiceClient")),
    Garden: GardenTypesClient.ReactiveGarden,
    
    OnSlotSelected: (slotId: GardenTypesShared.SlotId) -> (),
}

type ModuleData = {}

export type Module = typeof(Garden) & ModuleData

return Garden :: Module