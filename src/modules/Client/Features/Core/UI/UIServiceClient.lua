--[=[
    @class UIServiceClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local UITypesClient = require("UITypesClient")

-- [ Constants ] --

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local UIServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIInfos: { [string]: UITypesClient.UIInfo },
    _UIStates: { [string]: ValueObject.ValueObject<boolean> },
    _Screens: { [string]: ScreenGui }
}

export type Module = typeof(UIServiceClient) & ModuleData

-- [ Private Functions ] --
function UIServiceClient._CloseAllConflicted(self: Module, targetUIName: string)
    local UIInfo = self._UIInfos[targetUIName]
    local Conflicts = UIInfo.Conflicts
    
    for uiName, isOpened in self._UIStates do
        if uiName == targetUIName then
            continue
        end

        local Category: UITypesClient.Category = self._UIInfos[uiName].Category
        
        if Conflicts[Category] then
            self:CloseUI(uiName)
        end
    end
end

-- [ Public Functions ] --
function UIServiceClient.GetScreen(self: Module, screenName: string)
    local Screen = self._Screens[screenName]

    if not Screen then
        local PlayerGui = LocalPlayer.PlayerGui
        local NewScreen = Instance.new("ScreenGui")
        NewScreen.Name = screenName
        NewScreen.Parent = PlayerGui
        NewScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self._Screens[screenName] = NewScreen
        Screen = NewScreen
    end

    return Screen
end

function UIServiceClient.ToggleUI(self: Module, uiName: string)
    local IsOpened = self._UIStates[uiName].Value

    if IsOpened then
        self:CloseUI(uiName)
    else
        self:OpenUI(uiName)
    end
end

function UIServiceClient.OpenUI(self: Module, uiName: string)
    self:_CloseAllConflicted(uiName)

    self._UIStates[uiName].Value = true
end

function UIServiceClient.CloseUI(self: Module, uiName: string)
    self._UIStates[uiName].Value = false
end

function UIServiceClient.RegisterUI(self: Module, uiInfo: UITypesClient.UIInfo)
    self._UIInfos[uiInfo.UIName] = uiInfo
    local Opened = ValueObject.new(true)
    self._UIStates[uiInfo.UIName] = Opened
end

function UIServiceClient.ObserveUI(self: Module, uiName: string)
    return self._UIStates[uiName]:Observe()
end

function UIServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIInfos = {}
    self._UIStates = {}
    self._Screens = {}
end

function UIServiceClient.Start(self: Module)
    
end

return UIServiceClient :: Module