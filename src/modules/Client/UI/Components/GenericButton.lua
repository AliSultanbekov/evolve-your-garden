--[=[
    @class GenericButton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local Observable = require("Observable")

-- [ Components ] --
local Scaler = require("Scaler")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GenericButton = function(props: Props)
    local IsPressed = ValueObject.new(false)
    local Scale = Blend.Spring(
        Blend.Computed(
            IsPressed,
            function(pressed: boolean)
                return if pressed then 0.9 else 1
            end
        ),
        35
    )

    return Blend.New "ImageButton" {
        Position = props.Position or UDim2.fromScale(0.5, 0.5);
        Size = props.Size or UDim2.fromOffset(100, 100);
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5);
        BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1),
        BackgroundTransparency = props.BackgroundTransparency or 1,
        Image = props.Image or "";
        [Blend.OnEvent "Activated"] = function()
            if props.OnPressed then props.OnPressed() end
        end,
        [Blend.OnEvent "InputBegan"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                IsPressed.Value = true
            end
        end,
        [Blend.OnEvent "InputBegan"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                IsPressed.Value = true

                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        IsPressed.Value = false
                        conn:Disconnect()
                    end
                end)
            end
        end,
        [Blend.OnEvent "MouseLeave"] = function()
            IsPressed.Value = false
        end,
        [Blend.Children] = {
            Scaler({ Scale = Scale }),
            props.Children :: any
        }
    }
end

-- [ Types ] --
type Props = {
    Position: UDim2?,
    Size: UDim2?,
    AnchorPoint: Vector2?,
    BackgroundColor3: Color3?,
    BackgroundTransparency: number?,
    Image: string?,
    OnPressed: (() -> ())?,
    Children: { Observable.Observable<Instance> }?,
}
type ModuleData = {}

export type Module = typeof(GenericButton) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GenericButton :: Module