--[=[
    @class MouseServiceClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local Signal = require("Signal")
local Rx = require("Rx")
local Observable = require("Observable")

-- [ Constants ] --
local RAYCAST_DISTANCE = 100

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local MouseServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _HoveredInstance: ValueObject.ValueObject<Instance?>,
    _HoveredPosition: ValueObject.ValueObject<Vector2?>,
    Signals: {
        MousePressed: Signal.Signal<>,
        MouseReleased: Signal.Signal<>,
    },
    _RaycastParams: RaycastParams,
}

export type Module = typeof(MouseServiceClient) & ModuleData

-- [ Private Functions ] --
function MouseServiceClient._RecreateRaycastParams(self: Module)
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.IgnoreWater = true
    Params.FilterDescendantsInstances = { LocalPlayer.Character }

    return Params
end

function MouseServiceClient._UpdateHover(self: Module)
    local Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local MouseLocation = UserInputService:GetMouseLocation()
    local UnitRay = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
    local Result = Workspace:Raycast(UnitRay.Origin, UnitRay.Direction * RAYCAST_DISTANCE, self._RaycastParams)

    if Result then
        self._HoveredInstance.Value = Result.Instance
        self._HoveredPosition.Value = Result.Position
    else
        self._HoveredInstance.Value = nil
        self._HoveredPosition.Value = nil
    end
end

-- [ Public Functions ] --
function MouseServiceClient.ObserveOnClick(self: Module, targetInstance: Instance)
    return Observable.new(function(subscription): ((() -> ()) | Instance | RBXScriptConnection | any | thread)?
        local MaidObject = Maid.new()
        local IsHovering = false

        MaidObject:Add(self:ObserveIsHovering(targetInstance):Subscribe(function(hovered)
            IsHovering = hovered
        end))

        MaidObject:Add(self.Signals.MousePressed:Connect(function()
            if IsHovering then
                subscription:Fire()
            end
        end))

        return MaidObject
    end)
end

function MouseServiceClient.ObserveIsHovering(self: Module, targetInstance: Instance)
    return self._HoveredInstance:Observe():Pipe({
        Rx.map(function(instance: Instance?)
            return instance ~= nil and (instance:IsDescendantOf(targetInstance) or instance == targetInstance)
        end) :: any,
        Rx.distinct() :: any,
    })
end

function MouseServiceClient.ObserveHoveredModel(self: Module)
    return self._HoveredInstance:Observe():Pipe({
        Rx.map(function(instance: Instance?): Model?
            if not instance then
                return
            end

            return instance:FindFirstAncestorOfClass("Model")
        end) :: any,
        Rx.distinct() :: any,
    })
end

function MouseServiceClient.ObserveHoveredInstance(self: Module)
    return self._HoveredInstance:Observe()
end

function MouseServiceClient.ObserveHoveredPosition(self: Module)
    return self._HoveredPosition:Observe()
end

function MouseServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._HoveredInstance = ValueObject.new(nil)
    self._HoveredPosition = ValueObject.new(nil)
    self.Signals = {
        MousePressed = Signal.new(),
        MouseReleased = Signal.new()
    }
    self._RaycastParams = self:_RecreateRaycastParams()
end

function MouseServiceClient.Start(self: Module)
    self._Maid:Add(LocalPlayer.CharacterAdded:Connect(function(character: Model)
        self._RaycastParams = self:_RecreateRaycastParams()
    end))

    self._Maid:Add(RunService.RenderStepped:Connect(function(dt: number)
        self:_UpdateHover()
    end))

    self._Maid:Add(UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed then
            return
        end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Signals.MousePressed:Fire()
        end
    end))

    self._Maid:Add(UserInputService.InputEnded:Connect(function(input: InputObject, processed: boolean)
        if processed then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Signals.MouseReleased:Fire()
        end
    end))
end

return MouseServiceClient :: Module