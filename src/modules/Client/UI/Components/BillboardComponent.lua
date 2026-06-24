
--[=[
    @class BillboardComponent
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")
local Rx = require("Rx")
local Observable = require("Observable")
local Maid = require("Maid")

-- [ Components ] --
local ScalerComponent = require("ScalerComponent")

-- [ Constants ] --
local HIDDEN_VECTOR = Vector3.new(0, 0, -1)

-- [ Variables ] --

-- [ Module Table ] --

-- [ Functions ] --
local function GetWorldPosition(adornee, offset): Vector3?
    local Offset = offset or Vector3.zero
    if adornee:IsA("BasePart") then return adornee.CFrame:PointToWorldSpace(Offset)
    elseif adornee:IsA("Attachment") then return adornee.WorldCFrame:PointToWorldSpace(Offset)
    elseif adornee:IsA("PVInstance") then return adornee:GetPivot():PointToWorldSpace(Offset) 
    end

    return nil
end

local BillboardComponent = function(props: Props)
    local OnScreenVector = props.Adornee:Pipe({
        Rx.switchMap(function(adornee: Instance?)
            if not adornee then
                return Rx.of(HIDDEN_VECTOR) :: any
            end

            return Observable.new(function(subscription): ((() -> ()) | Instance | RBXScriptConnection | any | thread)?
                local MaidObject = Maid.new()
                MaidObject:Add(RunService.RenderStepped:Connect(function(dt: number)
                    local Camera = workspace.CurrentCamera

                    if not Camera then
                        return
                    end

                    local WorldPositon = GetWorldPosition(adornee, props.Offset)

                    if not WorldPositon then
                        subscription:Fire(HIDDEN_VECTOR)
                        return
                    end

                    subscription:Fire(Camera:WorldToScreenPoint(WorldPositon))
                end))
                return MaidObject
            end)
        end) :: any,
        Rx.shareReplay(1) :: any
    })

    return Blend.New "Frame" {
        Name = "Billboard";
        AnchorPoint = props.AnchorPoint;
        Size = UDim2.fromOffset(0, 0);
        BackgroundTransparency = 1;
        ZIndex = -100;
        Position = Blend.Computed(OnScreenVector, function(onScreenVector: Vector3)
            return UDim2.fromOffset(onScreenVector.X, onScreenVector.Y)
        end);
        Visible = Blend.Computed(OnScreenVector, function(onScreenVector: Vector3)
            return onScreenVector.Z > 0
        end);
        props.Children;
        ScalerComponent({
            Scale = Blend.Computed(OnScreenVector, function(onScreenVector: Vector3)
                return math.clamp(props.ReferenceDepth / onScreenVector.Z, props.MinScale, props.MaxScale)
            end);
            ApplyDeviceScale = false
        })
    }
end

-- [ Types ] --
type Props = {
    Adornee: Observable.Observable<Instance?>,
    Offset: Vector3?,
    AnchorPoint: ComponentTypes.Prop<Vector2>,
    Children: { Observable.Observable<Instance> }?,
    ReferenceDepth: number,
    MinScale: number,
    MaxScale: number,
}
type ModuleData = {}

export type Module = typeof(BillboardComponent) & ModuleData

return BillboardComponent :: Module