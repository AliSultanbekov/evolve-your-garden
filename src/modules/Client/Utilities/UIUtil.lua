--[=[
    @class UIUtil
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --
local DEFAULT_TWEEN = TweenInfo.new(0.1)

-- [ Variables ] --

-- [ Module Table ] --
local UIUtil = {}
UIUtil.Cache = {} :: {
    [any]: Tween
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(UIUtil) & ModuleData

-- [ Private Functions ] --
function UIUtil._CleanupTween(self: Module, ui: any)
    local Tween = self.Cache[ui]

    if not Tween then
        return
    end

    Tween:Destroy()

    self.Cache[ui] = nil
end

-- [ Public Functions ] --
function UIUtil.IsMouseOver(self: Module, ui: GuiObject, mousePos: Vector2?)
    local MousePos = mousePos or UserInputService:GetMouseLocation()
    local AbsPos = ui.AbsolutePosition
    local AbsSize = ui.AbsoluteSize
    
    return MousePos.X >= AbsPos.X 
        and MousePos.X <= AbsPos.X + AbsSize.X 
        and MousePos.Y >= AbsPos.Y
        and MousePos.Y <= AbsPos.Y + AbsSize.Y
end

function UIUtil.SetScale(self: Module, ui: GuiObject, value: number)
    local UIScale = ui:FindFirstChildOfClass("UIScale")

    if not UIScale then
        return
    end

    UIScale.Scale = value
end

function UIUtil.AnimateScale(self: Module, uiScale: UIScale, value: number, tweenInfo: TweenInfo?, onCompleted: () -> ()?)
    self:_CleanupTween(uiScale)

    local Tween = TweenService:Create(uiScale, tweenInfo or DEFAULT_TWEEN)

    self.Cache[uiScale] = Tween

    Tween.Completed:Connect(function(a0: Enum.PlaybackState)
        self:_CleanupTween(uiScale)

        if onCompleted then
            onCompleted()
        end
    end)

    Tween:Play()
end

function UIUtil.OpenUI(self: Module, ui: GuiObject, tweenInfo: TweenInfo?, onCompleted: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        local NewUIScale = Instance.new("UIScale")
        NewUIScale.Parent = ui
        NewUIScale.Scale = 0
        UIScale = NewUIScale
    end

    local NewScale = (UIScale:GetAttribute("SavedScale") :: number) or 1

    ui.Visible = true

    self:AnimateScale(UIScale, NewScale, tweenInfo, function()
        if onCompleted then
            onCompleted()
        end
    end)
end

function UIUtil.CloseUI(self: Module, ui: GuiObject, tweenInfo: TweenInfo, onCompleted: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        local NewUIScale = Instance.new("UIScale")
        NewUIScale.Parent = ui
        NewUIScale.Scale = 0
        UIScale = NewUIScale
    end

    local NewScale = 0

    self:AnimateScale(UIScale, NewScale, tweenInfo, function()
        ui.Visible = false

        if onCompleted then
            onCompleted()
        end
    end)
end

return UIUtil :: Module