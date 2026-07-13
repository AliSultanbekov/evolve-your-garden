--[=[
    @class Slot
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local MerchantConfig = require("MerchantConfig")
local MerchantTypesClient = require("MerchantTypesClient")
local Rx = require("Rx")
local NumberLocalizationUtils = require("NumberLocalizationUtils")
local RoundingBehaviourTypes = require("RoundingBehaviourTypes")
local ItemConfig = require("ItemConfig")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Slot = function(props: Props)
    local ItemName = props.Slot.ItemName:Observe()

    local BuyConfigData = ItemName:Pipe({
        Rx.map(function(itemName: string)
            return MerchantConfig.BuyItems[itemName]
        end) :: any
    })

    local Stock = props.Slot.Stock:Observe()
    local Left = props.Slot.Left:Observe()

    return Blend.New "Frame" {
        Name = "Slot";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(198, 250);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Rays";
            Position = UDim2.fromOffset(-18, -13);
            Size = UDim2.fromOffset(235, 235);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://70872696922786";
            ZIndex = 3;
        };
        Blend.New "ImageLabel" {
            Name = "Background";
            LayoutOrder = 1;
            Size = UDim2.fromOffset(198, 250);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://80176461971689";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
        Blend.New "Frame" {
            Name = "Price";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(9, 201);
            Size = UDim2.fromOffset(84, 36);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromOffset(84, 36);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://135865089252547";
            };
            Blend.New "ImageLabel" {
                Name = "Currency";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(4, 2);
                Size = UDim2.fromOffset(32, 32);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://102030151569914";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
            Blend.New "TextLabel" {
                Name = "Amount";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(36, 2);
                Size = UDim2.fromOffset(43, 32);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = Blend.Computed(BuyConfigData, function(buyConfigData: any)
                    if not buyConfigData then
                        return "0"
                    end

                    return NumberLocalizationUtils.abbreviate(buyConfigData.Price, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3)
                end);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextScaled = true;
                TextSize = 24;
                TextWrapped = true;
                ZIndex = 3;
                Blend.New "UITextSizeConstraint" {
                    MaxTextSize = 24;
                };
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 2;
                };
            };
        };
        GenericButtonComponent({
            Name = "Buy";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(105, 201);
            Size = UDim2.fromOffset(84, 36);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://89071506225026";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 4;
            OnPressed = function()
                props.Buy(props.Slot.Id)
            end;
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(76, 26);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Buy";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 20;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(14, 100, 13);
                        Thickness = 2;
                    };
                };
            }
        });
        Blend.New "ImageLabel" {
            Name = "Icon";
            LayoutOrder = 4;
            Position = UDim2.fromOffset(9, 14);
            Size = UDim2.fromOffset(180, 180);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            ScaleType = Enum.ScaleType.Fit;
            Image = Blend.Computed(ItemName, function(itemName: string?)
                if not itemName then
                    return ""
                end

                return ItemConfig:GetIcon(itemName, "Plant")
            end);
            ZIndex = 5;
        };
        Blend.New "TextLabel" {
            Name = "Stock";
            LayoutOrder = 5;
            Position = UDim2.fromOffset(129, 166);
            Size = UDim2.fromOffset(55, 30);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = Blend.Computed(Stock, Left, function(stock: number, left: number)
                return tostring(left) .. "/" .. tostring(stock)
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 22;
            ZIndex = 6;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 2;
            };
        };
        Blend.New "TextLabel" {
            Name = "Name";
            LayoutOrder = 6;
            Position = UDim2.fromOffset(6, 7);
            Size = UDim2.fromOffset(186, 34);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = Blend.Computed(ItemName, function(itemName: string?)
                return itemName or ""
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 22;
            ZIndex = 7;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 2;
            };
        };
    }
end

-- [ Types ] --
type Props = {
    Slot: MerchantTypesClient.ReactiveSlot,
    Buy: (slotId: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Slot) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Slot :: Module