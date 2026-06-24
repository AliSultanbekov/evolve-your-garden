
--[=[
    @class Window
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --
local BillboardComponent = require("BillboardComponent")
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local Observable = require("Observable")
local Rx = require("Rx")
local Maid = require("Maid")
local SoundUtil = require("SoundUtil")

-- [ Constants ] --
local SPEED = 13
local HOLD = 1

-- [ Variables ] --

-- [ Module Table ] --
local RenderStepped = Rx.fromSignal(RunService.RenderStepped):Pipe({
    Rx.share() :: any
})

local Window = function(props: Props)
    local MaidObject = Maid.new()

    local TypeState = props.Text:Pipe({
        Rx.switchMap(function(text: string?)
            if not text then
                return Rx.of({ Visible = 0, Done = true}) :: any
            end

            local Total = utf8.len(text) or #text
            return (RenderStepped :: any):Pipe({
                Rx.scan(function(elapsed, dt: number)
                    return (elapsed or 0) + dt 
                end, 0),
                Rx.map(function(elapsed: number)
                    local Visible = math.min(math.floor(elapsed * SPEED), Total)
                    local Done = elapsed >= (Total / SPEED) + HOLD
                    return { Visible = Visible, Done = Done}
                end) :: any,
                Rx.startWith({ { Visible = 0, Done = false } }) :: any,
            })
        end) :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    MaidObject:Add(TypeState:Pipe({
        Rx.map(function(state) return state.Done end),
        Rx.distinct() :: any,
    }):Subscribe(function(done: boolean)
        props.OnSpeakingChanged(not done)
    end))

    MaidObject:Add(TypeState:Pipe({
        Rx.map(function(state) return state.Visible end),
        Rx.distinct() :: any,
    }):Subscribe(function(visible: number)
        SoundUtil:PlaySound("NPC/Bleep")
    end))

    return BillboardComponent({
        Adornee = props.Adornee,
        ReferenceDepth = 30,
        MinScale = 0,
        MaxScale = 1.5,
        Offset = Vector3.new(0, 3, 0),
        Children = {
            AnimatedFrameComponent({
                IsOpen = props.IsOpen,
                Name = "Speech";
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromOffset(276, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                Children = {
                    Blend.New "ImageLabel" {
                        Name = "Background";
                        Size = UDim2.new(0, 276, 1, 24);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://95824691443002";
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(Vector2.new(527, 21), Vector2.new(527, 153));
                    };
                    Blend.New "Frame" {
                        Name = "Container";
                        LayoutOrder = 1;
                        Size = UDim2.fromOffset(276, 0);
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundTransparency = 1;
                        ClipsDescendants = true;
                        ZIndex = 2;
                        Blend.New "UIListLayout" {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center;
                            SortOrder = Enum.SortOrder.Name;
                            VerticalAlignment = Enum.VerticalAlignment.Center;
                        };
                        Blend.New "UIPadding" {
                            PaddingBottom = UDim.new(0, 15);
                            PaddingLeft = UDim.new(0, 20);
                            PaddingRight = UDim.new(0, 20);
                            PaddingTop = UDim.new(0, 20);
                        };
                        Blend.New "TextLabel" {
                            Name = "Text";
                            Size = UDim2.fromOffset(236, 0);
                            Position = UDim2.fromOffset(8, 8);
                            AutomaticSize = Enum.AutomaticSize.Y;
                            BackgroundTransparency = 1;
                            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic);
                            MaxVisibleGraphemes = TypeState:Pipe({
                                Rx.map(function(state)  
                                    return state.Visible
                                end),
                                Rx.distinct() :: any,
                            });
                            Text = props.Text:Pipe({ 
                                Rx.map(function(text: string?) return text or "" end) :: any,
                            });
                            TextColor3 = Color3.fromRGB(255, 255, 255);
                            TextSize = 16;
                            TextWrapped = true;
                            Blend.New "UIStroke" {
                                Color = Color3.fromRGB(43, 73, 112);
                                Thickness = 2;
                            };
                            [Blend.OnEvent "Destroying"] = function()
                                MaidObject:DoCleaning()
                            end;
                        };
                    };
                }
            })
        }
    })
end

-- [ Types ] --
type Props = {
    Adornee: Observable.Observable<Instance?>,
    IsOpen: Observable.Observable<boolean>,
    Text: Observable.Observable<string?>,
    OnSpeakingChanged: (value: boolean) -> (),
}

type ModuleData = {}

export type Module = typeof(Window) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Window :: Module