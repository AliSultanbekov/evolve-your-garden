--[=[
    @class SearchBar
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local SearchBar = function(props: Props)
    return Blend.New "Frame" {
        Name = "SearchBar";
        LayoutOrder = 4;
        Position = UDim2.fromOffset(703, 51);
        Size = UDim2.fromOffset(306, 64);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 5;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromOffset(306, 64);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://129977395166820";
        };
        Blend.New "TextBox" {
            Name = "Text";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(10, 9);
            Size = UDim2.fromOffset(330, 42);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            CursorPosition = -1;
            Text = "";
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 32;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 2;
            [Blend.OnChange "Text"] = function(text: string)
                props.OnSearch(text)
            end
        };
        Blend.New "TextBox" {
            Name = "SearchBox";
            LayoutOrder = 1;
            Size = UDim2.fromOffset(306, 64);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            CursorPosition = -1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            PlaceholderText = "Search...";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            PlaceholderColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 24;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 4;
            };
            [Blend.OnChange "Text"] = function(text: string)
                props.OnSearch(text)
            end
        };
    }
end

-- [ Types ] --
type Props = {
    OnSearch: (text: string) -> (),
}
type ModuleData = {}

export type Module = typeof(SearchBar) & ModuleData

return SearchBar :: Module