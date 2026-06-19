
--[=[
    @class ItemCard
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemConfig = require("ItemConfig")
local ItemUtil = require("ItemUtil")
local ValueObject = require("ValueObject")
local Rx = require("Rx")
local Maid = require("Maid")
local GradientUtil = require("GradientUtil")
local ComponentTypes = require("ComponentTypes")
local NumberLocalizationUtils = require("NumberLocalizationUtils")
local RoundingBehaviourTypes = require("RoundingBehaviourTypes")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --
local WIGGLE_COLORS = {
    Common = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(123, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 179, 255)),
    }),

    Uncommon = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 135, 65)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 224, 188)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 224, 188)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 155, 90)),
    }),

    Rare = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 85, 75)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 195, 185)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 195, 185)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 100, 90)),
    }),

    Epic = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 65, 160)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 185, 228)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 185, 228)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 85, 175)),
    }),

    Legendary = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 80)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 110, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 60)),
    }),

    Mythic = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 25)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 45, 60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 175, 160)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 45, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 10, 35)),
    }),

    Celestial = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 110)),
        ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 155, 50)),
        ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 235, 65)),
        ColorSequenceKeypoint.new(0.42, Color3.fromRGB(60, 235, 150)),
        ColorSequenceKeypoint.new(0.57, Color3.fromRGB(60, 210, 255)),
        ColorSequenceKeypoint.new(0.71, Color3.fromRGB(120, 105, 255)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(210, 60, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 95, 170)),
    }),
}

local WIGGLE_ANIMATIONS = {
    Legendary = function(time: number)
        return GradientUtil:GetColorSequence({
            BaseColorSequence = WIGGLE_COLORS["Legendary"],
            Resolution = 18,
            Width = 2,
            Speed = 1,
            Seed = 0,
        }, time)
    end,
    Mythic = function(time: number)
        return GradientUtil:GetColorSequence({
            BaseColorSequence = WIGGLE_COLORS["Mythic"],
            Resolution = 18,
            Width = 2,
            Speed = 1.2,
            Seed = 0,
        }, time)
    end,
    Celestial = function(time: number)
        return GradientUtil:GetColorSequence({
            BaseColorSequence = WIGGLE_COLORS["Celestial"],
            Resolution = 18,
            Width = 6,
            Speed = 1,
            Seed = 0,
        }, time)
    end
} :: {
    [string]: (time: number) -> ColorSequence
}

-- [ Variables ] --
local RenderStepped = Rx.fromSignal(RunService.RenderStepped):Pipe({
    Rx.share() :: any
})

-- [ Functions ] --

-- [ Module Table ] --
local ItemCardComponent = function(props: Props)
    local MaidObject = Maid.new()
    local Item = props.Item
    local ItemRarity = ItemConfig:GetRarity(Item.Name, Item.Category)
    local WiggleColor = ValueObject.new(WIGGLE_COLORS[ItemRarity])

    local WiggleAnimation = WIGGLE_ANIMATIONS[ItemRarity]

    if WiggleAnimation then
        MaidObject:Add((RenderStepped :: any):Pipe({
            Rx.scan(function(acc, dt: number) return (acc or 0) + dt end, 0),
        }):Subscribe(function(elapsed: number)
            WiggleColor.Value = WiggleAnimation(elapsed)
        end))
    end

    return GenericButtonComponent({
        Name = "ItemCard";
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        Visible = props.Visible;
        Parent = props.Parent;
        Children = {
            Blend.New "ImageLabel" {
                Name = "Wiggle";
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                Image = "rbxassetid://104856123058042";
                ScaleType = Enum.ScaleType.Fit;
                [Blend.Children] = {
                    Blend.New "UIGradient" {
                        Color = WiggleColor;
                        Rotation = 180;
                    }
                }
            };
            Blend.New "ImageLabel" {
                Name = "Icon";
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromScale(0.88, 0.88);
                BackgroundTransparency = 1;
                ScaleType = Enum.ScaleType.Fit;
                Image = ItemConfig:GetIcon(Item.Name, Item.Category);
            };
            if ItemUtil:CategoryToStorageMode(Item.Category) == "Stackable" then
                Blend.New "TextLabel" {
                    Name = "Amount";
                    Position = UDim2.fromOffset(58, 82);
                    Size = UDim2.fromOffset(54, 30);
                    Text = Blend.Computed((Item  :: ReactiveItemTypes.ReactiveStackableItem).Amount, function(amount: number)
                        return NumberLocalizationUtils.abbreviate(amount, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3);
                    end);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 25;
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(43, 73, 112);
                        Thickness = 3;
                    };
                } :: any
            else nil 
        },
        OnPressed = function(buttonInstance: GuiButton)
            local backing = buttonInstance.Parent :: GuiButton

            if not backing then
                return
            end

            local pos = backing.AbsolutePosition

            props.OnItemPressed(Item, UDim2.fromOffset(pos.X, pos.Y))
        end,
        OnHovered = function(buttonInstance: GuiButton)
            local backing = buttonInstance.Parent :: GuiButton

            if not backing then
                return
            end

            local pos = backing.AbsolutePosition

            props.OnItemHovered(Item, UDim2.fromOffset(pos.X, pos.Y))
        end,
        OnUnhovered = function()
            props.OnItemUnhovered()
        end,
        OnDestroyed = function()
            MaidObject:DoCleaning()
        end
    })
end

-- [ Types ] --
type Props = {
    Item: ReactiveItemTypes.ReactiveItem,
    Visible: ComponentTypes.Prop<boolean>?,
    Parent: ComponentTypes.Prop<Instance>?,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
}
type ModuleData = {}

export type Module = typeof(ItemCardComponent) & ModuleData

return ItemCardComponent :: Module