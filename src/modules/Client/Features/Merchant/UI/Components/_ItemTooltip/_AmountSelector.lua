--[=[
    @class AmountSelector
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local NumberLocalizationUtils = require("NumberLocalizationUtils")
local RoundingBehaviourTypes = require("RoundingBehaviourTypes")
local ValueObject = require("ValueObject")
local Rx = require("Rx")
local Maid = require("Maid")
local MerchantConfig = require("MerchantConfig")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local AnimatedFrameComponent = require("AnimatedFrameComponent")

-- [ Constants ] --
local KNOB_TRAVEL = 189

-- [ Variables ] --

-- [ Module Table ] --
local AmountSelector = function(props: Props)
    local MaidObject = Maid.new()
    local IsDraggerPressed = ValueObject.new(false)
    local DraggerFrame: Frame? = nil
    local CurrentMax = 1

    MaidObject:GiveTask(props.SelectedItemMaxSellAmount:Subscribe(function(max: number)
        CurrentMax = math.max(max, 1)
    end))

    MaidObject:GiveTask(IsDraggerPressed:Observe():Pipe({
        Rx.switchMap(function(pressed: boolean)
            if not pressed then
                return Rx.of(nil) :: any
            end

            return props.MousePosition :: any
        end) :: any,
    }):Subscribe(function(position: Vector2?)
        if not position or not DraggerFrame then
            return
        end

        local Alpha = math.clamp((position.X - DraggerFrame.AbsolutePosition.X) / DraggerFrame.AbsoluteSize.X, 0, 1)
        local Amount = math.clamp(1 + math.round(Alpha * (CurrentMax - 1)), 1, CurrentMax)

        props.SetSelectedItemSellAmount(Amount)
    end))

    local DraggerPosition = Blend.Computed(props.SelectedItemSellAmount, props.SelectedItemMaxSellAmount, function(amount: number, max: number)
        local Alpha = if max <= 1 then 1 else (amount - 1) / (max - 1)

        return UDim2.fromOffset(math.round(Alpha * KNOB_TRAVEL), 0)
    end)

    return AnimatedFrameComponent({
        Name = "AmountSelector";
        IsOpen = props.IsSelected;
        Position = UDim2.fromOffset(250/2, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(250, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Children = {
            Blend.New "UIPadding" {
                PaddingTop = UDim.new(0, 10);
                [Blend.OnEvent "Destroying"] = function()
                    MaidObject:DoCleaning()
                end;
            };
            GenericButtonComponent({
                Name = "Decrement";
                Position = UDim2.fromOffset(14 + 44/2, 70 + 4 + 47/2);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromOffset(44, 47);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://81259944626191";
                ScaleType = Enum.ScaleType.Fit;
                OnPressed = function()
                    props.DecrementSelectedItemSellAmount()
                end;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Name";
                        Position = UDim2.fromOffset(4, 4);
                        Size = UDim2.fromOffset(36, 36);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = "-";
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 38;
                        TextWrapped = true;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(130, 40, 40);
                            Thickness = 2;
                        };
                    };
                };
            });
            GenericButtonComponent({
                Name = "Increment";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(194 + 40/2, 70 + 6 + 43/2);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromOffset(40, 43);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 2;
                OnPressed = function()
                    props.IncrementSelectedItemSellAmount()
                end;
                Children = {
                    Blend.New "ImageLabel" {
                        Name = "Increment";
                        Position = UDim2.fromOffset(-2, -2);
                        Size = UDim2.fromOffset(44, 47);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://133552324118692";
                        ScaleType = Enum.ScaleType.Fit;
                    };
                    Blend.New "TextLabel" {
                        Name = "Name";
                        LayoutOrder = 1;
                        Position = UDim2.fromOffset(2, 2);
                        Size = UDim2.fromOffset(36, 36);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = "+";
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 38;
                        TextWrapped = true;
                        ZIndex = 2;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(14, 100, 13);
                            Thickness = 2;
                        };
                    };
                };
            });
            Blend.New "ImageLabel" {
                Name = "Display";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(63, 69);
                Size = UDim2.fromOffset(124, 57);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://128423489958085";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 3;
                Blend.New "TextLabel" {
                    Name = "Amount";
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(116, 49);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = Blend.Computed(props.SelectedItemSellAmount, function(selectedItemSellAmount: number)
                        return NumberLocalizationUtils.abbreviate(selectedItemSellAmount, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3)
                    end);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 38;
                    TextWrapped = true;
                    ZIndex = 3;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(43, 73, 112);
                        Thickness = 2;
                    };
                };
            };
            Blend.New "Frame" {
                Name = "Dragger";
                LayoutOrder = 3;
                Position = UDim2.fromOffset(22, 70 + 67);
                Size = UDim2.fromOffset(206, 21);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 4;
                [Blend.Instance] = function(frame: Frame)
                    DraggerFrame = frame
                end;
                Blend.New "ImageLabel" {
                    Name = "Background";
                    Position = UDim2.fromOffset(0, 5);
                    Size = UDim2.fromOffset(206, 12);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://109375707632012";
                    ScaleType = Enum.ScaleType.Fit;
                };
                Blend.New "ImageButton" {
                    Name = "Dragger";
                    LayoutOrder = 1;
                    Position = DraggerPosition;
                    Size = UDim2.fromOffset(17, 21);
                    AutoButtonColor = false;
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://92985387099967";
                    ZIndex = 2;
                    [Blend.OnEvent "InputBegan"] = function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                           or input.UserInputType == Enum.UserInputType.Touch then
                            IsDraggerPressed.Value = true

                            local conn
                            conn = input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    IsDraggerPressed.Value = false
                                    conn:Disconnect()
                                end
                            end)
                        end
                    end;
                };
            };
            Blend.New "Frame" {
                Name = "SellPrice";
                LayoutOrder = 4;
                Position = UDim2.fromOffset(0, 0);
                Size = UDim2.fromOffset(250, 60);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 5;
                Blend.New "ImageLabel" {
                    Name = "Union";
                    Position = UDim2.fromOffset(86, 25);
                    Size = UDim2.fromOffset(30, 30);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://114575618265862";
                    ScaleType = Enum.ScaleType.Fit;
                };
                Blend.New "ImageLabel" {
                    Name = "coin golden 4";
                    LayoutOrder = 1;
                    Position = UDim2.fromOffset(85, 24);
                    Size = UDim2.fromOffset(32, 32);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://82367982581365";
                    ZIndex = 2;
                };
                Blend.New "TextLabel" {
                    Name = "Price";
                    LayoutOrder = 2;
                    Position = UDim2.fromOffset(122, 24);
                    Size = UDim2.fromOffset(54, 32);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = Blend.Computed(props.SelectedItemSellAmount, props.Item, function(selectedItemSellAmount: number, item: ReactiveItemTypes.ReactiveItem?)
                        if not item then
                            return ""
                        end

                        local Price = selectedItemSellAmount * MerchantConfig.SellItems[item.Name].Price

                        return NumberLocalizationUtils.abbreviate(Price, "en-us", RoundingBehaviourTypes.ROUND_TO_CLOSEST, 3)
                    end);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 19;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 3;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(43, 73, 112);
                        Thickness = 2;
                    };
                };
                Blend.New "TextLabel" {
                    Name = "Info";
                    LayoutOrder = 3;
                    Position = UDim2.fromOffset(61, 0);
                    Size = UDim2.fromOffset(127, 20);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "You'll Receive:";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 19;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 4;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(43, 73, 112);
                        Thickness = 2;
                    };
                };
            };
        }
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    IsSelected: Observable.Observable<boolean>,
    SelectedItemSellAmount: Observable.Observable<number>,
    SelectedItemMaxSellAmount: Observable.Observable<number>,
    MousePosition: Observable.Observable<Vector2>,

    IncrementSelectedItemSellAmount: () -> ();
    DecrementSelectedItemSellAmount: () -> ();
    SetSelectedItemSellAmount: (amount: number) -> ();
}
type ModuleData = {}

export type Module = typeof(AmountSelector) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return AmountSelector :: Module