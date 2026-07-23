--[=[
    @class SearchBar
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local SearchBarComponent = require("SearchBarComponent")
local Observable = require("Observable")

-- [ Components ] --

-- [ Constants ] --
local ACTIVE_POSITION = UDim2.fromOffset(752, 662)
local INACTIVE_POSITION = UDim2.fromOffset(752, 550)

-- [ Variables ] --

-- [ Module Table ] --
local SearchBar = function(props: Props)
    return SearchBarComponent({
        Size = UDim2.fromOffset(330, 88);
        BackgroundImage = "rbxassetid://75381649147413";
        SearchBoxSize = UDim2.fromOffset(300, 58);
        TextBoxStrokeColor = Color3.fromRGB(97, 61, 34);
        Position = Blend.Spring(Blend.Computed(props.ActiveTab, function(activeTab: string)
                if activeTab == "Sell" then
                    return ACTIVE_POSITION
                else
                    return INACTIVE_POSITION
                end
            end),
            20,
            1
        );
        SearchBoxPosition = UDim2.fromOffset(15, 15);
        ZIndex = 2;
        PlaceholderText = "Search...";
        OnSearch = props.OnSearch;
    })
end

-- [ Types ] --
type Props = {
    OnSearch: (text: string) -> (),
    ActiveTab: Observable.Observable<string>
}
type ModuleData = {}

export type Module = typeof(SearchBar) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return SearchBar :: Module