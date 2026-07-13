--[=[
    @class TabButtons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ImagesConfig = require("ImagesConfig")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TabButtons = function(props: Props)
    return Blend.New "Frame" {
        Name = "TabButtons";
        LayoutOrder = 5;
        Position = UDim2.fromOffset(619, 9);
        Size = UDim2.fromOffset(375, 64);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 6;
        GenericButtonComponent({
            Name = "Buy";
            Position = UDim2.fromOffset(181/2, 64/2);
            Size = UDim2.fromOffset(181, 64);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = Blend.Computed(props.ActiveTab, function(tab: string)
                if tab == "Buy" then
                    return ImagesConfig.Merchant.Buttons.Active
                end

                return ImagesConfig.Merchant.Buttons.Inactive
            end);
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
            OnPressed = function()
                props.SwitchTab("Buy")
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(6, 6);
                    Size = UDim2.fromOffset(169, 49);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Buy";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 24;
                    Blend.New "UIStroke" {
                        Color = Blend.Computed(props.ActiveTab, function(tab: string)
                            if tab == "Buy" then
                                return Color3.fromRGB(15, 72, 14)
                            end
            
                            return Color3.fromRGB(97, 61, 34);
                        end);
                        Thickness = 3;
                    };
                }; 
            }
        });
        GenericButtonComponent({
            Name = "Sell";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(194+181/2, 0+64/2);
            Size = UDim2.fromOffset(181, 64);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = Blend.Computed(props.ActiveTab, function(tab: string)
                if tab == "Sell" then
                    return ImagesConfig.Merchant.Buttons.Active
                end

                return ImagesConfig.Merchant.Buttons.Inactive
            end);
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
            OnPressed = function()
                props.SwitchTab("Sell")
            end,
            Children = {
                Blend.New "TextLabel" {
                    Name = "Name";
                    Position = UDim2.fromOffset(6, 6);
                    Size = UDim2.fromOffset(169, 49);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Sell";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 24;
                    Blend.New "UIStroke" {
                        Color = Blend.Computed(props.ActiveTab, function(tab: string)
                            if tab == "Sell" then
                                return Color3.fromRGB(15, 72, 14)
                            end
            
                            return Color3.fromRGB(97, 61, 34);
                        end);
                        Thickness = 3;
                    };
                };
            }

        })
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: Observable.Observable<string>,
    SwitchTab: (string) -> (),
}
type ModuleData = {}

export type Module = typeof(TabButtons) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return TabButtons :: Module