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
    summary = "Encyclopedia window: bookmark rail (+ claimable badge), plants grid with discovered/undiscovered cards. Toggle TomatoDiscovered to watch a card reveal live.",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local ActiveTab = ValueObject.new("Plants")
        local ClaimableCount = ValueObject.new(controls.ClaimableCount)

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

        -- Seed one discovered plant so both card variants show immediately.
        local SnowBlossom = GetDiscoveredItem("Snow Blossom")
        SnowBlossom.DiscoveredTime.Value = DateTime.now().UnixTimestamp
        SnowBlossom.TotalAcquired.Value = 12

        if props.subscribe then
            props.subscribe(function(values: typeof(controls))
                ClaimableCount.Value = values.ClaimableCount

                local Tomato = GetDiscoveredItem("Tomato")
                if values.TomatoDiscovered then
                    Tomato.DiscoveredTime.Value = DateTime.now().UnixTimestamp
                    Tomato.TotalAcquired.Value = 3
                else
                    Tomato.DiscoveredTime.Value = nil
                    Tomato.TotalAcquired.Value = 0
                end
            end)
        end

        MaidObject:Add(Blend.mount(props.target, {
            EncyclopediaComponent({
                IsOpen = IsOpen:Observe(),
                ActiveTab = ActiveTab:Observe(),
                ClaimableCount = ClaimableCount:Observe(),
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
