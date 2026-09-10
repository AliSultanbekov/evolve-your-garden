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
local EncyclopediaTypesClient = require("EncyclopediaTypesClient")

-- [ Components ] --
local EncyclopediaComponent = require(script.Parent.Parent.Components.EncyclopediaComponent)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    ClaimableCount = 3,
    TomatoDiscovered = false,
}

-- [ Module Table ] --
local EncyclopediaStory = {
    summary = "Encyclopedia window: bookmark rail (+ claimable badge), plants grid with discovered/undiscovered cards. Toggle TomatoDiscovered to watch a card reveal and the discovered counter move live.",
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
        SetDiscovered("Snow Blossom", DateTime.now().UnixTimestamp, 12)

        if props.subscribe then
            props.subscribe(function(values: typeof(controls))
                ClaimableCount.Value = values.ClaimableCount

                if values.TomatoDiscovered then
                    SetDiscovered("Tomato", DateTime.now().UnixTimestamp, 3)
                else
                    SetDiscovered("Tomato", nil, 0)
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
