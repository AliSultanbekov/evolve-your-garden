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
            Name = "Background";
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://107768709566747";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "Rays";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-6, 20);
            Size = UDim2.fromOffset(210, 210);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://139446929646805";
            ZIndex = 2;
        };
        Blend.New "Frame" {
            Name = "Price";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(9, 204);
            Size = UDim2.fromOffset(87, 33);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 7;
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromScale(1, 1);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://88199061584130";
            };
            Blend.New "ImageLabel" {
                Name = "Currency";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(4, 2);
                Size = UDim2.fromOffset(29, 29);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://81633986587985";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
            Blend.New "TextLabel" {
                Name = "Amount";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(35, 2);
                Size = UDim2.fromOffset(48, 29);
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
                TextSize = 29;
                TextWrapped = true;
                ZIndex = 3;
                Blend.New "UITextSizeConstraint" {
                    MaxTextSize = 29;
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
            Position = UDim2.fromOffset(102, 204);
            Size = UDim2.fromOffset(87, 33);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://98094527641326";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 6;
            OnPressed = function()
                props.Buy(props.Slot.Id)
            end;
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(79, 23);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                    Text = "Buy";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 19;
                    TextWrapped = true;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(15, 100, 9);
                        Thickness = 2;
                    };
                };
            }
        });
        Blend.New "ImageLabel" {
            Name = "Icon";
            LayoutOrder = 4;
            Position = UDim2.fromOffset(6, 6);
            Size = UDim2.fromOffset(186, 193);
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
            ZIndex = 3;
        };
        Blend.New "TextLabel" {
            Name = "Stock";
            LayoutOrder = 5;
            Position = UDim2.fromOffset(122, 169);
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
            Position = UDim2.fromOffset(6, 6);
            Size = UDim2.fromOffset(186, 35);
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