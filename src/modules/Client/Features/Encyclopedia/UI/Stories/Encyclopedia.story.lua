--[=[
    @class EncyclopediaStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")
local EncyclopediaTypesClient = require("EncyclopediaTypesClient")
local QuestsTypesClient = require("QuestsTypesClient")

-- [ Components ] --
local EncyclopediaComponent = require(script.Parent.Parent.Components.EncyclopediaComponent)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    ClaimableCount = 3,
    TomatoDiscovered = false,
    CoolQuestCompleted = false,
    QuestProgress = 0.4,
}

-- [ Module Table ] --
local EncyclopediaStory = {
    summary = "Encyclopedia window: bookmark rail (+ claimable badge), plants grid with discovered/undiscovered cards, Rewards tab with a live quest card. Toggle TomatoDiscovered for a card reveal; toggle CoolQuestCompleted then press Claim to watch the quest card burn out of the grid.",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local ActiveTab = ValueObject.new("Plants")
        local ClaimableCount = ValueObject.new(controls.ClaimableCount)
        local DiscoveredPlantsCount = ValueObject.new(0)

        -- Lazy per-plant reactive discovery state; same table returned on
        -- repeat calls, like the real EncyclopediaServiceClient mirror will.
        local DiscoveredItems: { [string]: EncyclopediaTypesClient.ReactiveDiscoveredItem } = {}

        local function GetDiscoveredItem(itemName: string): EncyclopediaTypesClient.ReactiveDiscoveredItem
            local Existing = DiscoveredItems[itemName]

            if Existing then
                return Existing
            end

            local ReactiveItem = {
                DiscoveredTime = ValueObject.new(nil :: number?),
                TotalAcquired = ValueObject.new(0),
            }
            DiscoveredItems[itemName] = ReactiveItem

            return ReactiveItem
        end

        -- Single write path for the mirror, like the real service: writes the
        -- per-plant state AND maintains the derived count in one place.
        local function SetDiscovered(itemName: string, discoveredTime: number?, totalAcquired: number)
            local ReactiveItem = GetDiscoveredItem(itemName)
            local WasDiscovered = ReactiveItem.DiscoveredTime.Value ~= nil

            ReactiveItem.DiscoveredTime.Value = discoveredTime
            ReactiveItem.TotalAcquired.Value = totalAcquired

            if not WasDiscovered and discoveredTime then
                DiscoveredPlantsCount.Value += 1
            elseif WasDiscovered and not discoveredTime then
                DiscoveredPlantsCount.Value -= 1
            end
        end

        -- Seed one discovered plant so both card variants show immediately.
        SetDiscovered("Daisy", DateTime.now().UnixTimestamp, 12)

        -- Quest mirror: ids MUST exist in QuestsConfig (QuestCard reads
        -- Description etc. from config by id). "Cool Quest" is the seeded one.
        local Quests = ObservableMap.new()
        local QuestProgress = ValueObject.new(controls.QuestProgress)
        local CoolQuest: QuestsTypesClient.ReactiveQuest = {
            Id = "Cool Quest",
            StartTime = DateTime.now().UnixTimestamp,
            State = ValueObject.new("Active") :: any,
            Anchors = {},
        }
        Quests:Set(CoolQuest.Id, CoolQuest)

        if props.subscribe then
            props.subscribe(function(values: typeof(controls))
                ClaimableCount.Value = values.ClaimableCount
                QuestProgress.Value = math.clamp(values.QuestProgress, 0, 1)

                if values.TomatoDiscovered then
                    SetDiscovered("Tomato", DateTime.now().UnixTimestamp, 3)
                else
                    SetDiscovered("Tomato", nil, 0)
                end

                -- Burnt -> Active also exercises the card remount path.
                if values.CoolQuestCompleted then
                    CoolQuest.State.Value = "Completed"
                else
                    CoolQuest.State.Value = "Active"
                end
            end)
        end

        MaidObject:Add(Blend.mount(props.target, {
            EncyclopediaComponent({
                IsOpen = IsOpen:Observe(),
                ActiveTab = ActiveTab:Observe(),
                ClaimableCount = ClaimableCount:Observe(),
                DiscoveredPlantsCount = DiscoveredPlantsCount:Observe(),
                GetDiscoveredItem = GetDiscoveredItem,
                Quests = Quests,
                ObserveQuestProgress = function(_questId: string)
                    return QuestProgress:Observe()
                end,
                -- Mimic the server's OneTime claim: Completed -> Burnt, so
                -- claiming makes the card leave the grid live.
                OnClaimQuest = function(questId: string)
                    print("[Story] ClaimQuest:", questId)

                    local Quest = Quests:Get(questId)

                    if Quest and Quest.State.Value == "Completed" then
                        Quest.State.Value = "Burnt"
                    end
                end,

                SwitchTab = function(tabName: string)
                    print("[Story] SwitchTab:", tabName)
                    ActiveTab.Value = tabName
                end,
                OnSearch = function(text: string)
                    print("[Story] Search:", text)
                end,
                OnClose = function()
                    IsOpen.Value = false
                end,
            })
        }))

        return function()
            MaidObject:Destroy()
        end
    end
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(EncyclopediaStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return EncyclopediaStory :: Module
