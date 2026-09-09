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
local RxCharacterUtils = require("RxCharacterUtils")

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
    _MousePosition: ValueObject.ValueObject<Vector2>,
    Signals: {
        MousePressed: Signal.Signal<(Instance?, Vector2)>,
        MouseReleased: Signal.Signal<>,
    },
    _RaycastParams: RaycastParams,
}

export type Module = typeof(MouseServiceClient) & ModuleData

-- [ Private Functions ] --
function MouseServiceClient._RecreateRaycastParams(self: Module, character: Model?)
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.IgnoreWater = true
    -- A nil character must yield an EMPTY list — { nil } would silently
    -- exclude nothing and let pointer raycasts hit the player's own body.
    Params.FilterDescendantsInstances = if character then { character } else {}

    return Params
end

function MouseServiceClient._RaycastAtPointer(self: Module): RaycastResult?
    local Camera = workspace.CurrentCamera

    if not Camera then
        return nil
    end

    -- _MousePosition is in GUI space (InputObject.Position, inset-subtracted) —
    -- ScreenPointToRay is the matching raycast for that space. Do NOT switch to
    -- ViewportPointToRay unless the position source changes to GetMouseLocation.
    local Location = self._MousePosition.Value
    local UnitRay = Camera:ScreenPointToRay(Location.X, Location.Y)

    return Workspace:Raycast(UnitRay.Origin, UnitRay.Direction * RAYCAST_DISTANCE, self._RaycastParams)
end

function MouseServiceClient._UpdateHover(self: Module)
    local Result = self:_RaycastAtPointer()

    if Result then
        self._HoveredInstance.Value = Result.Instance
        self._HoveredPosition.Value = self._MousePosition.Value
    else
        self._HoveredInstance.Value = nil
        self._HoveredPosition.Value = nil
    end
end

-- [ Public Functions ] --
function MouseServiceClient.ObserveMousePosition(self: Module)
    return self._MousePosition:Observe()
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
    self._HoveredInstance = ValueObject.new()
    self._HoveredPosition = ValueObject.new()
    self._MousePosition = ValueObject.new(Vector2.new())
    self.Signals = {
        MousePressed = Signal.new(),
        MouseReleased = Signal.new(),
    } :: any
    self._RaycastParams = self:_RecreateRaycastParams(LocalPlayer.Character)
end

function MouseServiceClient.Start(self: Module)
    self._Maid:Add(RxCharacterUtils.observeLocalPlayerCharacter():Subscribe(function(character: Model?)
        self._RaycastParams = self:_RecreateRaycastParams(character)
    end))

    -- One coordinate space for everything: InputObject.Position (GUI space,
    -- inset-subtracted) for BOTH mouse and touch. UI consumers compare against
    -- AbsolutePosition (same space) and the raycast uses ScreenPointToRay
    -- (which expects this space). Mixing in GetMouseLocation (viewport space)
    -- offsets everything vertically by the GUI inset.
    local PendingPosition: Vector2? = nil
    local PendingIsTouch = false

    self._Maid:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            PendingPosition = Vector2.new(input.Position.X, input.Position.Y)
            PendingIsTouch = false
        elseif input.UserInputType == Enum.UserInputType.Touch then
            PendingPosition = Vector2.new(input.Position.X, input.Position.Y)
            PendingIsTouch = true
        end
    end))

    self._Maid:Add(RunService.RenderStepped:Connect(function()
        if not PendingPosition then
            return
        end

        self._MousePosition.Value = PendingPosition
        PendingPosition = nil

        -- Hover is a mouse concept: on touch the "hover" would just be
        -- wherever the finger last was, which reads as stuck highlights.
        -- Selection is unaffected (it uses the press-time raycast).
        if PendingIsTouch then
            self._HoveredInstance.Value = nil
            self._HoveredPosition.Value = nil
        else
            self:_UpdateHover()
        end
    end))

    self._Maid:Add(UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._MousePosition.Value = Vector2.new(input.Position.X, input.Position.Y)

            local Result = self:_RaycastAtPointer()

            self.Signals.MousePressed:Fire(Result and Result.Instance, self._MousePosition.Value)
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
