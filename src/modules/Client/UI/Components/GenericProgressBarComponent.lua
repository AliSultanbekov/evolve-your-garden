--[=[
    @class GenericProgressBarComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GenericProgressBarComponent = function(props: Props)
    -- Shared by Fill, InnerStroke and the optional fill-hugging OuterStroke
    -- so they always agree on the filled width.
    local FillWidth = Blend.Computed(props.Progress, function(progress)
        return UDim2.fromScale(progress, 0) + UDim2.fromOffset(if progress <= 0.1 then props.FillSize.X.Offset else 0, props.FillSize.Y.Offset)
    end)

    -- At 0% a zero-width fill still renders its border stroke as a small
    -- blob at the left edge — hide the fill layers entirely instead.
    local HasProgress = Blend.Computed(props.Progress, function(progress)
        return progress > 0
    end)

    return Blend.New "Frame" {
        Name = "ProgressBar";
        LayoutOrder = 1;
        Position = props.Position;
        Size = props.Size;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 2;
        Blend.New "CanvasGroup" {
            Name = "Canvas";
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            Blend.New "Frame" {
                Name = "BarBackground";
                Position = props.BarBackgroundPosition;
                Size = props.BarBackgroundSize;
                BackgroundColor3 = props.BarBackgroundColor3;
                Blend.New "UICorner" {
                    BottomLeftRadius = UDim.new(0, props.UICorner);
                    BottomRightRadius = UDim.new(0, props.UICorner);
                    CornerRadius = UDim.new(0, props.UICorner);
                    TopLeftRadius = UDim.new(0, props.UICorner);
                    TopRightRadius = UDim.new(0, props.UICorner);
                };
                Blend.New "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Color = props.BarBackgroundUIStokeColor;
                    Thickness = props.BarBackgroundUIStokeSize;
                };
            };
            Blend.New "UICorner" {
                BottomLeftRadius = UDim.new(0, props.UICorner);
                BottomRightRadius = UDim.new(0, props.UICorner);
                CornerRadius = UDim.new(0, props.UICorner);
                TopLeftRadius = UDim.new(0, props.UICorner);
                TopRightRadius = UDim.new(0, props.UICorner);
            };
            Blend.New "ImageLabel" {
                Name = "Fill";
                LayoutOrder = 1;
                Position = props.FillPosition;
                Size = FillWidth;
                Visible = HasProgress;
                -- No FillImage = flat mode: the frame itself is the fill and
                -- the UIGradient colors it.
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = if props.FillImage then 1 else 0;
                ClipsDescendants = true;
                Image = props.FillImage;
                ScaleType = if props.SliceCenter then Enum.ScaleType.Slice else nil;
                SliceCenter = props.SliceCenter;
                ZIndex = 2;
                Blend.New "UICorner" {
                    CornerRadius = UDim.new(0, props.FillUICorner or 0);
                };
                Blend.New "UIGradient" {
                    Color = props.FillColorSequence;
                    Rotation = props.FillGradientRotation or 0;
                };
                -- Flat-mode inner highlight: emulates UIStroke's beta
                -- BorderStrokePosition = Inner (which errors at runtime) with
                -- an inset frame whose border stroke hugs the fill's inside.
                -- Invisible unless FillInnerStrokeThickness is set.
                Blend.New "Frame" {
                    Name = "InnerHighlight";
                    Position = UDim2.fromOffset(props.FillInnerStrokeThickness or 0, props.FillInnerStrokeThickness or 0);
                    Size = UDim2.new(1, -2 * (props.FillInnerStrokeThickness or 0), 1, -2 * (props.FillInnerStrokeThickness or 0));
                    BackgroundTransparency = 1;
                    Blend.New "UICorner" {
                        CornerRadius = UDim.new(0, props.FillUICorner or 0);
                    };
                    Blend.New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(255, 255, 255);
                        Thickness = props.FillInnerStrokeThickness or 0;
                        Blend.New "UIGradient" {
                            Color = props.FillInnerStrokeColorSequence or ColorSequence.new(Color3.fromRGB(255, 255, 255));
                            Rotation = props.FillGradientRotation or 0;
                        };
                    };
                };
            };
            Blend.New "ImageLabel" {
                Name = "InnerStroke";
                LayoutOrder = 2;
                Visible = HasProgress;
                Position = props.InnerStrokePosition or props.FillPosition;
                Size = Blend.Computed(props.Progress, function(progress)
                    local InnerStrokeSize = props.InnerStrokeSize or props.FillSize

                    return UDim2.fromScale(progress, 0) + UDim2.fromOffset(if progress <= 0.1 then props.FillSize.X.Offset else 0, InnerStrokeSize.Y.Offset)
                end);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = props.InnerStrokeImage;
                ScaleType = if props.SliceCenter then Enum.ScaleType.Slice else nil;
                SliceCenter = props.SliceCenter;
                ZIndex = 3;
                Blend.New "UIGradient" {
                    Color = props.InnerStrokeColorSequence
                };
            };
        };
        -- Outside the CanvasGroup so the border stroke isn't clipped at the
        -- bar bounds. Invisible unless FillStrokeThickness is set.
        Blend.New "Frame" {
            Name = "OuterStroke";
            Position = props.FillPosition;
            Size = FillWidth;
            Visible = HasProgress;
            BackgroundTransparency = 1;
            ZIndex = 3;
            Blend.New "UICorner" {
                CornerRadius = UDim.new(0, props.FillUICorner or 0);
            };
            Blend.New "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Color = props.FillStrokeColor or Color3.fromRGB(255, 255, 255);
                Thickness = props.FillStrokeThickness or 0;
            };
        };
        props.Children;
    }
end

-- [ Types ] --
type Props = {
    Position: UDim2,
    Size: UDim2,
    FillImage: string?,
    FillColorSequence: ColorSequence,
    FillGradientRotation: number?,
    FillUICorner: number?,
    FillStrokeColor: Color3?,
    FillStrokeThickness: number?,
    FillInnerStrokeColorSequence: ColorSequence?,
    FillInnerStrokeThickness: number?,
    InnerStrokeImage: string?,
    InnerStrokeColorSequence: ColorSequence?,
    BarBackgroundPosition: UDim2,
    BarBackgroundSize: UDim2,
    BarBackgroundUIStokeSize: number,
    BarBackgroundUIStokeColor: Color3,
    BarBackgroundColor3: Color3,
    FillSize: UDim2,
    FillPosition: UDim2,
    InnerStrokeSize: UDim2?,
    InnerStrokePosition: UDim2?,
    UICorner: number,
    SliceCenter: Rect?,
    Children: { any }?,

    Progress: Observable.Observable<number>
}
type ModuleData = {}

export type Module = typeof(GenericProgressBarComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GenericProgressBarComponent :: Module