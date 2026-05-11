--[=[
    @class ItemCard
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemConfig = require("ItemConfig")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local GenericTextComponent = require("GenericTextComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemCardComponent = function(props: Props)
    local Item = props.Item

    return GenericButtonComponent({
        OnPressed = function() props.OnPressed(Item) end,
        Children = {
            Blend.New "ImageLabel" {
                Name = "Wiggle",
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = "rbxassetid://114302431590952",
                ScaleType = Enum.ScaleType.Fit,
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(64, 179, 255),
                ZIndex = 1,
            },
            Blend.New "ImageLabel" {
                Name = "Icon",
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.9, 0.9),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = ItemConfig:GetIcon(Item.Name, Item.Category),
                ScaleType = Enum.ScaleType.Fit,
                BackgroundTransparency = 1,
                ZIndex = 2,
            },

            if Item.Category == "Material" then
                GenericTextComponent({
                    Name = "Amount",
                    TextSize = 30,
                    Position = UDim2.new(1, -19, 1, -19),
                    Text = Blend.Computed(Item.Amount, function(amount: number)
                        return "x" .. amount
                    end),
                    StrokeColor = Color3.fromRGB(50, 87, 122),
                }) :: any
            else nil,
        }
    })
end

-- [ Types ] --
type Props = {
    Item: ReactiveItemTypes.ReactiveItem,
    OnPressed: (item: ReactiveItemTypes.ReactiveItem) -> (),
}
type ModuleData = {}

export type Module = typeof(ItemCardComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ItemCardComponent :: Module