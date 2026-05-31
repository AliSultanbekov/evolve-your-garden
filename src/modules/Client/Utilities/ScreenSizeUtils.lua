--[=[
    @class ScreenSizeUtils
]=]

-- [ Roblox Services ] --
local Workspace = game:GetService("Workspace")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ValueObject = require("ValueObject")
local Blend = require("Blend")

-- [ Constants ] --
local DEFAULT_DESIGN_SIZE = Vector2.new(1920, 1080)

-- [ Variables ] --
local viewportSize = ValueObject.new(
    Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or DEFAULT_DESIGN_SIZE
)

local cameraConnection: RBXScriptConnection? = nil

local function bindCamera(camera: Camera)
    if cameraConnection then
        cameraConnection:Disconnect()
    end
    viewportSize.Value = camera.ViewportSize
    cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        viewportSize.Value = camera.ViewportSize
    end)
end

if Workspace.CurrentCamera then
    bindCamera(Workspace.CurrentCamera)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if Workspace.CurrentCamera then
        bindCamera(Workspace.CurrentCamera)
    end
end)

-- [ Module Table ] --
local ScreenSizeUtils = {}

-- [ Public Functions ] --
function ScreenSizeUtils.ObserveViewport(): ValueObject.ValueObject<Vector2>
    return viewportSize
end

function ScreenSizeUtils.ComputeScale(designSize: Vector2?)
    local reference = designSize or DEFAULT_DESIGN_SIZE
    return Blend.Computed(viewportSize, function(viewport: Vector2)
        return math.min(0.9, math.min(viewport.X / reference.X, viewport.Y / reference.Y))
    end)
end

return ScreenSizeUtils