--[=[
    @class PlantCard

    One encyclopedia grid cell (149x189). Two variants per the design:
    undiscovered (grey card, big "?" and "???" name) and discovered
    (colored card, item name). STRUCTURE ONLY — props are plain values;
    reactive wiring (observables, icon lookup, press handling) is left
    to the caller.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local PlantsConfig = require("PlantsConfig")
local Observable = require("Observable")
local ImagesConfig = require("ImagesConfig")
local ItemConfig = require("ItemConfig")

-- [ Components ] --

-- [ Constants ] --
-- Name-label stroke per rarity, applied through a UIGradient over a white
-- stroke so every rarity (including Celestial's rainbow) is one code path.
local RARITY_TO_NAME_STROKE_COLOR_SEQUENCE = {
    Common = ColorSequence.new(Color3.fromRGB(43, 73, 112)),
    Uncommon = ColorSequence.new(Color3.fromRGB(101, 65, 23)),
    Rare = ColorSequence.new(Color3.fromRGB(113, 27, 27)),
    Epic = ColorSequence.new(Color3.fromRGB(96, 29, 88)),
    Legendary = ColorSequence.new(Color3.fromRGB(95, 74, 23)),
    Mythic = ColorSequence.new(Color3.fromRGB(67, 34, 112)),
    Celestial = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 16, 16)),
        ColorSequenceKeypoint.new(0.075, Color3.fromRGB(80, 16, 16)),
        ColorSequenceKeypoint.new(0.217, Color3.fromRGB(71, 50, 14)),
        ColorSequenceKeypoint.new(0.361, Color3.fromRGB(71, 67, 16)),
        ColorSequenceKeypoint.new(0.496, Color3.fromRGB(13, 63, 16)),
        ColorSequenceKeypoint.new(0.639, Color3.fromRGB(14, 61, 68)),
        ColorSequenceKeypoint.new(0.78, Color3.fromRGB(15, 27, 68)),
        ColorSequenceKeypoint.new(0.917, Color3.fromRGB(94, 23, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 23, 38)),
    }),
}

local UNDISCOVERED_NAME_STROKE_COLOR_SEQUENCE = ColorSequence.new(Color3.fromRGB(62, 62, 62))

-- [ Variables ] --

-- [ Module Table ] --
local PlantCard = function(props: Props)
    local PlantRarity = ItemConfig:GetRarity(props.PlantName, "Plant")
    
    return Blend.New "ImageButton" {
        Name = "PlantCard";
        LayoutOrder = props.LayoutOrder;
        Size = UDim2.fromOffset(149, 189);
        Active = false;
        Selectable = false;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromOffset(149, 189);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = Blend.Computed(props.IsDiscovered, function(isDiscovered: boolean)
                if not isDiscovered then
                    return ImagesConfig.Encyclopedia.PlantCardBackgrounds.Undiscovered
                else
                    return ImagesConfig.Encyclopedia.PlantCardBackgrounds[PlantRarity]
                end
            end);
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "Wiggle";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(7, 7);
            Size = UDim2.fromOffset(135, 135);
            ImageColor3 = Blend.Computed(props.IsDiscovered, function(isDiscovered: boolean)
                if not isDiscovered then
                    return Color3.fromRGB(99, 99, 99);
                else
                    return Color3.fromRGB(255, 255, 255);
                end
            end);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://95120585507106";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
        Blend.New "ImageLabel" {
            Name = "Icon";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(7, 7);
            Size = UDim2.fromOffset(135, 135);
            ImageColor3 = Blend.Computed(props.IsDiscovered, function(isDiscovered: boolean)
                if not isDiscovered then
                    return Color3.fromRGB(0, 0, 0);
                else
                    return Color3.fromRGB(255, 255, 255);
                end
            end);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = PlantsConfig.Plants[props.PlantName].Icon;
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 3;
        };
        Blend.New "TextLabel" {
            Name = "Name";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(8, 152);
            Size = UDim2.fromOffset(133, 29);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = Blend.Computed(props.IsDiscovered, function(isDiscovered: boolean)
                if not isDiscovered then
                    return "???";
                else
                    return props.PlantName;
                end
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 17;
            TextWrapped = true;
            ZIndex = 4;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(255, 255, 255);
                Thickness = 2;
                Blend.New "UIGradient" {
                    Color = Blend.Computed(props.IsDiscovered, function(isDiscovered: boolean)
                        if not isDiscovered then
                            return UNDISCOVERED_NAME_STROKE_COLOR_SEQUENCE
                        else
                            return RARITY_TO_NAME_STROKE_COLOR_SEQUENCE[PlantRarity]
                        end
                    end);
                };
            };
        };
    }
end

-- [ Types ] --
type Props = {
    PlantName: string,
    LayoutOrder: number,
    IsDiscovered: Observable.Observable<boolean>
}
type ModuleData = {}

export type Module = typeof(PlantCard) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantCard :: Module
