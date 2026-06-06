
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
local Observable = require("Observable")
local NumberLocalizationUtils = require("NumberLocalizationUtils")
local RoundingBehaviourTypes = require("RoundingBehaviourTypes")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local GenericTextComponent = require("GenericTextComponent")

-- [ Constants ] --
local WIGGLE_COLORS = {
    Common = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    }),

    Uncommon = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 158, 62)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 171, 97)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(197, 137, 54)),
    }),

    Rare = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 90, 230)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 230, 255)),
    }),

    Epic = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 110, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 30, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 130, 255)),
    }),

    Legendary = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 80)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 110, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 60)),
    }),

    Mythic = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 90)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(120, 0, 30)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(255, 90, 130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 0, 40)),
    }),

    Celestial = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHex("#D62C2C")),
        ColorSequenceKeypoint.new(0.17, Color3.fromHex("#FFAE3D")),
        ColorSequenceKeypoint.new(0.34, Color3.fromHex("#FFE943")),
        ColorSequenceKeypoint.new(0.51, Color3.fromHex("#6AFF6D")),
        ColorSequenceKeypoint.new(0.68, Color3.fromHex("#51F3FF")),
        ColorSequenceKeypoint.new(0.85, Color3.fromHex("#3741FF")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#FF45C7")),
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
            Width = 2.5,
            Speed = 0.8,
            Seed = 0,
        }, time)
    end,
    Celestial = function(time: number)
        return GradientUtil:GetColorSequence({
            BaseColorSequence = WIGGLE_COLORS["Celestial"],
            Resolution = 18,
            Width = 2,
            Speed = 0.5,
            Seed = 0,
        }, time)
    end
} :: {
    [string]: (time: number) -> ()
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
        Size = UDim2.fromOffset(100, 100);
        BackgroundTransparency = 1;
        Visible = props.Visible;
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
                        Rotation = 125;
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
                GenericTextComponent({
                    Name = "Amount";
                    Position = UDim2.fromOffset(58, 82);
                    Size = UDim2.fromOffset(54, 30);
                    Text = Blend.Computed((Item  :: ReactiveItemTypes.ReactiveStackableItem).Amount, function(amount: number)
                        return NumberLocalizationUtils.abbreviate(amount, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3);
                    end);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 25;
                    StrokeColor = Color3.fromRGB(0, 71, 97);
                    StrokeThickness = 3;
                }) :: any
            else nil 
        },
        OnPressed = function(buttonInstance: GuiButton)
            local pos = buttonInstance.AbsolutePosition
            props.OnItemPressed(Item, UDim2.fromOffset(pos.X, pos.Y))
        end,
        OnHovered = function(buttonInstance: GuiButton)
            local pos = buttonInstance.AbsolutePosition
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
    Visible: Observable.Observable<boolean>,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
}
type ModuleData = {}

export type Module = typeof(ItemCardComponent) & ModuleData

return ItemCardComponent :: Module