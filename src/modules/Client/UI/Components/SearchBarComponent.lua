--[=[
    @class SearchBarComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SearchBarComponent = function(props: Props)
    return Blend.New "Frame" {
        Name = "SearchBar";
        LayoutOrder = props.LayoutOrder;
        Position = props.Position;
        Size = props.Size;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = props.ZIndex;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = props.BackgroundImage;
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "TextBox" {
            Name = "SearchText";
            LayoutOrder = 1;
            Position = props.SearchBoxPosition;
            Size = props.SearchBoxSize;
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            CursorPosition = -1;
            Text = "";
            PlaceholderText = props.PlaceholderText or "Search...";
            PlaceholderColor3 = Color3.fromRGB(255, 255, 255);
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 24;
            TextWrapped = true;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
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
    Size: UDim2,
    BackgroundImage: string,
    SearchBoxSize: UDim2,
    OnSearch: (text: string) -> (),
    Position: UDim2?,
    SearchBoxPosition: UDim2?,
    LayoutOrder: number?,
    ZIndex: number?,
    PlaceholderText: string?,
}
type ModuleData = {}

export type Module = typeof(SearchBarComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return SearchBarComponent :: Module
