--[=[
    @class SearchBar

    Flat-frame search drawer hanging below the merchant window's bottom-right.
    Springs down when the Sell tab is active (search only filters sell items)
    and tucks back up behind the window otherwise.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Components ] --

-- [ Constants ] --
local ACTIVE_POSITION = UDim2.fromOffset(728, 661)
local INACTIVE_POSITION = UDim2.fromOffset(728, 550)

-- [ Variables ] --

-- [ Module Table ] --
local SearchBar = function(props: Props)
    return Blend.New "Frame" {
        Name = "SearchBar";
        LayoutOrder = 5;
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
        Size = UDim2.fromOffset(356, 91);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 2;
        Blend.New "Frame" {
            Name = "Body";
            Position = UDim2.fromOffset(3, 4);
            Size = UDim2.fromOffset(350, 85);
            BackgroundColor3 = Color3.fromRGB(106, 207, 255);
            BorderSizePixel = 0;
            Blend.New "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Color = Color3.fromRGB(43, 73, 112);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 3;
            };
        };
        Blend.New "Frame" {
            Name = "InnerBody";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(12, 13);
            Size = UDim2.fromOffset(331, 65);
            BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            BackgroundTransparency = 0.65;
            BorderSizePixel = 0;
            ZIndex = 2;
            Blend.New "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Color = Color3.fromRGB(43, 73, 112);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 3;
            };
        };
        Blend.New "TextBox" {
            Name = "SearchBox";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(15, 16);
            Size = UDim2.fromOffset(324, 60);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            PlaceholderColor3 = Color3.fromRGB(255, 255, 255);
            PlaceholderText = "Search...";
            Text = "";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 29;
            TextWrapped = true;
            ZIndex = 3;
            [Blend.OnChange "Text"] = function(text: string)
                props.OnSearch(text)
            end;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
    }
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
