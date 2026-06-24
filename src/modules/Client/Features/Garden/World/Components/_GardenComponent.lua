--[=[
    @class Garden
]=]

-- [ Roblox Services ] --

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
local SlotComponent = require(script.Parent._SlotComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function SetupGardenModel(model: GardenTypesClient.GardenModel, gardenId: GardenTypesShared.GardenId)
    model.Parent = workspace.World.Gardens[gardenId]

    return model
end

local function GetSlotCFrame(gardenModel: GardenTypesClient.GardenModel, level: number, slot: number)
    local Stats = GardenConfig.UpgradeStats[level]
    local OriginCFrame = gardenModel.SlotsSpawnPoint.WorldCFrame
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

-- [ Module Table ] --
local GardenComponent = function(props: Props)
    local MaidObject = Maid.new()
    local GardenMaid = MaidObject:Add(Maid.new())
    local Garden = props.Garden

    MaidObject:Add(Rx.combineLatest({
        Owner = Garden.Owner:Observe(),
        Level = Garden.Level:Observe(),
    }):Pipe({
        Rx.where(function(data)
            GardenMaid:DoCleaning()

            return if data.Owner and data.Level then true else false
        end) :: any
    }):Subscribe(function(data: { Owner: string, Level: number })
        local GardenModel = GardenMaid:Add(
            SetupGardenModel(
                AssetProvider:Get(
                    string.format("Objects/Garden/Upgrades/%s", tostring(data.Level))
                ),
                Garden.Id
            )
        ) :: GardenTypesClient.GardenModel

        GardenMaid:Add(function()
            props.OnGardenDestroyed()
        end)

        props.OnGardenCreated(GardenModel)

        GardenMaid:Add(Garden.Slots:ObservePairsBrio():Subscribe(function(brio: Brio.Brio<GardenTypesShared.SlotId, GardenTypesClient.ReactiveSlot>)
            if brio:IsDead() then 
                return 
            end

            local SlotMaid: Maid.Maid, SlotId: GardenTypesShared.SlotId, Slot: GardenTypesClient.ReactiveSlot = brio:ToMaidAndValue()

            local SlotNumber = tonumber(SlotId)

            if not SlotNumber then
                return
            end

            SlotMaid:Add(SlotComponent({
                Slot = Slot,
                SlotCFrame = GetSlotCFrame(GardenModel, data.Level, SlotNumber),
                GardenModel = GardenModel,

                OnSlotCreated = function(slotModel: GardenTypesClient.SlotModel)
                    props.OnSlotCreated(SlotId, slotModel)
                end,
                OnSlotDestroyed = function(slotModel: GardenTypesClient.SlotModel)
                    props.OnSlotDestroyed(SlotId, slotModel)
                end
            }))
        end))
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    Garden: GardenTypesClient.ReactiveGarden,

    OnGardenCreated: (gardenModel: GardenTypesClient.GardenModel) -> (),
    OnGardenDestroyed: () -> (),
    OnSlotCreated: (slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel) -> (),
    OnSlotDestroyed: (slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel) -> (),
}
type ModuleData = {}

export type Module = typeof(GardenComponent) & ModuleData

return GardenComponent :: Module