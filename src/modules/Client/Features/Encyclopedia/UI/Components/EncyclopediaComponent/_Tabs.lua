--[=[
    @class Tabs

    Tab container of the encyclopedia window. Hosts one frame per bookmark
    tab (Plants / Packs / Rewards). STRUCTURE ONLY — tab switching is left
    to the caller.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local EncyclopediaTypesClient = require("EncyclopediaTypesClient")
local ComponentTypes = require("ComponentTypes")
local Observable = require("Observable")

-- [ Components ] --
local Plants = require(script.Parent._Plants)
local Rewards = require(script.Parent._Rewards)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Tabs = function(props: Props)
    return Blend.New "Frame" {
        Name = "Tabs";
        LayoutOrder = 2;
        Position = UDim2.fromOffset(4, 96);
        Size = UDim2.fromOffset(1154, 669);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        ZIndex = 3;
        Plants({
            ActiveTab = props.ActiveTab;
            DiscoveredPlantsCount = props.DiscoveredPlantsCount;
            GetDiscoveredItem = props.GetDiscoveredItem,
            SwitchTab = props.SwitchTab
        });
        Rewards({
            ActiveTab = props.ActiveTab;
        });
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    DiscoveredPlantsCount: Observable.Observable<number>,
    GetDiscoveredItem: (itemName: string) -> EncyclopediaTypesClient.ReactiveDiscoveredItem,
    SwitchTab: (tabName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Tabs :: Module
