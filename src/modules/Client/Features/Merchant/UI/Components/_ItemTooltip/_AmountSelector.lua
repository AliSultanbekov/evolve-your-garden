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
                Position = UDim2.fromOffset(14 + 44/2, 4 + 47/2);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromOffset(44, 47);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://124788886396857";
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
                Position = UDim2.fromOffset(194 + 40/2, 6 + 43/2);
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
                        Image = "rbxassetid://121274968241695";
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
            Blend.New "Frame" {
                Name = "Display";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(63, 0);
                Size = UDim2.fromOffset(124, 57);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 3;
                Blend.New "Frame" {
                    Name = "Body";
                    Position = UDim2.fromOffset(2, 2);
                    Size = UDim2.fromOffset(120, 53);
                    BackgroundColor3 = Color3.fromRGB(35, 106, 160);
                    BorderColor3 = Color3.fromRGB(27, 42, 53);
                    Blend.New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(43, 73, 112);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 2;
                    };
                };
                Blend.New "Frame" {
                    Name = "Body";
                    LayoutOrder = 1;
                    Position = UDim2.fromOffset(2, 2);
                    Size = UDim2.fromOffset(120, 50);
                    BackgroundColor3 = Color3.fromRGB(51, 167, 255);
                    BorderColor3 = Color3.fromRGB(27, 42, 53);
                    ZIndex = 2;
                    Blend.New "Frame" {
                        Name = "InnerStroke";
                        Position = UDim2.fromScale(0.5, 0.5);
                        AnchorPoint = Vector2.new(0.5, 0.5);
                        Size = UDim2.new(1, -4, 1, -4);
                        BackgroundTransparency = 1;
                        Blend.New "UIStroke" {
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                            Color = Color3.fromRGB(147, 209, 255);
                            LineJoinMode = Enum.LineJoinMode.Miter;
                            Thickness = 2;
                        };
                    };
                };
                Blend.New "TextLabel" {
                    Name = "Name";
                    LayoutOrder = 2;
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(116, 46);
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
                Position = UDim2.fromOffset(22, 67);
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
                    Image = "rbxassetid://122114888109433";
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
                    Image = "rbxassetid://103093798185699";
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
        }
    })
end

-- [ Types ] --
type Props = {
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