--[=[
    @class GenericSkeleton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --
local Observable = require("Observable")

-- [ Module Table ] --
local GenericSkeletonComponent = function(props: Props)
    return Blend.New "Frame" {
        Name = "Content",
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        [Blend.Children] = {
            Blend.New "UIListLayout" {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Top
            },
            Blend.New "UIPadding" {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
            },
            if props.Header then Blend.New "Frame" {
                Name = "Header",
                Size = props.Header.Size,
                Position = props.Header.Position,
                AnchorPoint = props.Header.AnchorPoint,
                BackgroundTransparency = 1,
                [Blend.Children] = {
                    props.Header.Children
                }
            } else nil :: any,
            if props.Body then Blend.New "Frame" {
                Name = "Body",
                Size = props.Body.Size,
                Position = props.Body.Position,
                AnchorPoint = props.Body.AnchorPoint,
                BackgroundTransparency = 1,
                [Blend.Children] = {
                    props.Body.Children
                }
            } else nil :: any,
        }
    }
end

-- [ Types ] --
export type Element = {
    Size: UDim2?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Children: { Observable.Observable<Instance> }?,
}

type Props = {
    Header: Element?,
    Body: Element?
}
type ModuleData = {}

export type Module = typeof(GenericSkeletonComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GenericSkeletonComponent :: Module