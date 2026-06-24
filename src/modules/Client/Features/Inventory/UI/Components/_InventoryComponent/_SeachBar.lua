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
        LayoutOrder = 3;
        Position = UDim2.fromOffset(831, 9);
        Size = UDim2.fromOffset(306, 64);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromOffset(306, 64);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://129977395166820";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "TextBox" {
            Name = "SearchText";
            LayoutOrder = 1;
            Size = UDim2.fromOffset(306, 64);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            CursorPosition = -1;
            Text = "";
            PlaceholderText = "Search...";
            PlaceholderColor3 = Color3.fromRGB(255, 255, 255);
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 25;
            TextWrapped = true;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(32, 83, 118);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 3;
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