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
                Size = Blend.Computed(props.Progress, function(progress)
                    return UDim2.fromScale(progress, 0) + UDim2.fromOffset(if progress <= 0.1 then props.FillSize.X.Offset else 0, props.FillSize.Y.Offset)
                end);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = props.FillImage;
                ScaleType = if props.SliceCenter then Enum.ScaleType.Slice else nil;
                SliceCenter = props.SliceCenter;
                ZIndex = 2;
                Blend.New "UIGradient" {
                    Color = props.FillColorSequence
                };
            };
            Blend.New "ImageLabel" {
                Name = "InnerStroke";
                LayoutOrder = 2;
                Position = props.InnerStrokePosition;
                Size = Blend.Computed(props.Progress, function(progress)
                    return UDim2.fromScale(progress, 0) + UDim2.fromOffset(if progress <= 0.1 then props.FillSize.X.Offset else 0, props.InnerStrokeSize.Y.Offset)
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
        props.Children;
    }
end

-- [ Types ] --
type Props = {
    Position: UDim2,
    Size: UDim2,
    FillImage: string,
    FillColorSequence: ColorSequence,
    InnerStrokeImage: string,
    InnerStrokeColorSequence: ColorSequence,
    BarBackgroundPosition: UDim2,
    BarBackgroundSize: UDim2,
    BarBackgroundUIStokeSize: number,
    BarBackgroundUIStokeColor: Color3,
    BarBackgroundColor3: Color3,
    FillSize: UDim2,
    FillPosition: UDim2,
    InnerStrokeSize: UDim2,
    InnerStrokePosition: UDim2,
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