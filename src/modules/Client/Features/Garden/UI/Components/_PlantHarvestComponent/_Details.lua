--[=[
    @class Details
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local GardenTypesClient = require("GardenTypesClient")
local Rx = require("Rx")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemConfig = require("ItemConfig")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Details = function(props: Props)
    local DisplayItem = props.Slot:Pipe({
        Rx.switchMap(function(slot: GardenTypesClient.ReactiveSlot?)
            if not slot then
                return Rx.of(nil) :: any
            end

            return slot.Plant:Observe()
        end) :: any,
    }) :: any

    return Blend.New "Frame" {
        Name = "Detail";
        LayoutOrder = 5;
        Position = UDim2.fromOffset(28, 120);
        Size = UDim2.fromOffset(352, 346);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 6;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://139285285080863";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "Icon";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(26, 22);
            Size = UDim2.fromOffset(304, 304);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ScaleType = Enum.ScaleType.Fit;
            Image = Blend.Computed(DisplayItem, function(displayItem: ReactiveItemTypes.ReactiveItem?)
                if not displayItem then
                    return ""
                end

                return ItemConfig:GetIcon(displayItem.Name, displayItem.Category) or ""
            end);
            ZIndex = 2;
        };
        Blend.New "TextLabel" {
            Name = "Name";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(38, 9);
            Size = UDim2.fromOffset(280, 39);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = Blend.Computed(DisplayItem, function(displayItem: ReactiveItemTypes.ReactiveItem?)
                if not displayItem then
                    return ""
                end

                return displayItem.Name
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 28;
            ZIndex = 3;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Rarity";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(120, 47);
            Size = UDim2.fromOffset(116, 34);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://99294470631790";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 4;
        };
    }
end

-- [ Types ] --
type Props = {
    Slot: Observable.Observable<GardenTypesClient.ReactiveSlot?>,
}
type ModuleData = {}

export type Module = typeof(Details) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Details :: Module