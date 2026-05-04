--[=[
    @class UIScaleComponent
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local AttributeValue = require("AttributeValue")
local Maid = require("Maid")

-- [ Constants ] --
local DEFAULT_SCALE = 1
local MIN_SCALE = 0.5
local MAX_SCALE = 1.2
local TARGET_RESOLUTION = Vector2.new(1920, 1080)

-- [ Variables ] --
local Camera = workspace.CurrentCamera
local CurrentScale = DEFAULT_SCALE
local GlobalMaid = Maid.new()

-- [ Module Table ] --
local UIScaleComponent = {}
UIScaleComponent.__index = UIScaleComponent
UIScaleComponent.Tag = "UIScaleComponent"

-- [ Types ] --
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,

    _Maid: Maid.Maid,
    _Instance: UIScale,
    _Attributes: {
        IsAnimating: AttributeValue.AttributeValue<boolean>,
        SavedScale: AttributeValue.AttributeValue<number>,
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, UIScaleComponent))
export type Module = typeof(UIScaleComponent)

-- [ Private Functions ] --
function UpdateScale(binder: Binder.Binder<any>)
    local Viewport = Camera.ViewportSize

    local WidthRatio = Viewport.X / TARGET_RESOLUTION.X
    local HeightRatio = Viewport.Y / TARGET_RESOLUTION.Y

    local AverageRatio = (WidthRatio+HeightRatio)/2
    local CalculatedScale = math.clamp(AverageRatio, MIN_SCALE, MAX_SCALE)
    
    CurrentScale = CalculatedScale

    for _, Component: Object in binder:GetAll() do
        Component:ApplyScale()
    end
end

-- [ Public Functions ] --
function UIScaleComponent.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, UIScaleComponent) :: Object

    if not instance:IsA("UIScale") then
        error("[UIScaleComponentClient] Attempt to initialize on non-UIScale instance (" .. instance.ClassName .. ")")
    end
    
    self._ServiceBag = serviceBag

    self._Maid = Maid.new()
    self._Instance = instance
    self._Attributes = {
        IsAnimating = AttributeValue.new(instance, "IsAnimating", false),
        SavedScale = AttributeValue.new(instance, "SavedScale", DEFAULT_SCALE)
    }

    return self
end

function UIScaleComponent.ApplyScale(self: Object)
    local Parent = self._Instance.Parent

    if not Parent or not Parent:IsA("GuiObject") then
        warn("[UIScaleComponentClient] Parent is missing or not a GuiObject for UIScale instance: " .. tostring(self._Instance))
        return
    end

    if self._Instance.Scale ~= 0 and self._Attributes.IsAnimating.Value == false and Parent.Visible == true then
        self._Instance.Scale = CurrentScale
    end

    self._Attributes.SavedScale.Value = CurrentScale
end

function UIScaleComponent.Binded(self: Object)
    self:ApplyScale()
end

function UIScaleComponent.UnBinded(_self: Object)
    
end

function UIScaleComponent.Start(binder: Binder.Binder<Object>, _serviceBag: ServiceBag.ServiceBag)
    GlobalMaid:GiveTask(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        UpdateScale(binder)
    end))

    UpdateScale(binder)
end

return UIScaleComponent :: Module