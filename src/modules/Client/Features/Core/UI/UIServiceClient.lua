
--[=[
    @class UIServiceClient

    --Screen
    --UI
    --UIElement
    --UIGroup

]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local UIConfig = require("./_UIConfig")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Promise = require("Promise")
local UIUtil = require("UIUtil")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local UIServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Screens: { [string]: ScreenGui },
    _UIs: { [string]: GuiObject },
    _UICategories: { [string]: string },
    _UIElements: { [string]: {
        [string]: GuiObject
    }},
    _UIGroups: { [string]: {
        [string]: { GuiObject }
    }},
    _OpenUIs: { [string]: boolean },
    _UIReady: Promise.Promise<any>
}

export type Module = typeof(UIServiceClient) & ModuleData

-- [ Private Functions ] --
function UIServiceClient._RegisterInterface(self: Module)
    local PlayerGui = LocalPlayer.PlayerGui
    
    local Screens = PlayerGui:QueryDescendants(".Screen")

    for _, screen in Screens do
        local ScreenName = screen:GetAttribute("Name") :: string?

        if not ScreenName then
            continue
        end

        self._Screens[ScreenName] = screen

        local UIs = screen:QueryDescendants(".UI")

        for _, ui in UIs do
            local UIName = ui:GetAttribute("Name") :: string?
            local UICategory = ui:GetAttribute("Category") :: string?

            if not UIName then
                continue
            end

            if not UICategory then
                continue
            end

            self._UIs[UIName] = ui
            self._UICategories[UIName] = UICategory

            local UIElements = ui:QueryDescendants(".UIElement")
            local UIGroups = ui:QueryDescendants(".UIGroup")

            for _, uiElement in UIElements do
                local ElementName = ui:GetAttribute("Name") :: string?

                if not ElementName then
                    continue
                end

                if not self._UIElements[UIName] then
                    self._UIElements[UIName] = {}
                end
                
                self._UIElements[UIName][ElementName] = uiElement
            end

            for _, uiGroup in UIGroups do
                local GroupName = ui:GetAttribute("Name") :: string?

                if not GroupName then
                    continue
                end

                if not self._UIGroups[UIName] then
                    self._UIGroups[UIName] = {}
                end

                if not self._UIGroups[UIName][GroupName] then
                    self._UIGroups[UIName][GroupName] = {}
                end

                table.insert(self._UIGroups[UIName][GroupName], uiGroup)
            end
        end
    end

    self._UIReady:Resolve()
end

function UIServiceClient._CloseConflictedUIs(self: Module, uiToBeOpened: string)
    local NewUICategory = self._UICategories[uiToBeOpened]
    local ConflictedCategories = UIConfig.Conflicts[NewUICategory]

    for _, uiName in self._OpenUIs do
        local UICategory = self._UICategories[uiName]
        
        if ConflictedCategories[UICategory] then
            self:CloseUI(uiName)
        end
    end
end

-- [ Public Functions ] --
function UIServiceClient.ToggleUI(self: Module, uiName: string)
    if self._OpenUIs[uiName] then
        self:CloseUI(uiName)
    else
        self:OpenUI(uiName)
    end
end

function UIServiceClient.OpenUI(self: Module, uiName: string)
    local UI = self._UIs[uiName]
    local UIScale = UI:FindFirstChildOfClass("UIScale")

    if not UIScale then
        return
    end

    self:_CloseConflictedUIs(uiName)

    self._OpenUIs[uiName] = true

    UIScale:SetAttribute("IsAnimating", true)

    UIUtil:OpenUI(UI, OPEN_TWEENINFO, function()
        UIScale:SetAttribute("IsAnimating", false)
    end)
end

function UIServiceClient.CloseUI(self: Module, uiName: string)
    local UI = self._UIs[uiName]
    local UIScale = UI:FindFirstChildOfClass("UIScale")

    if not UIScale then
        return
    end

    UIScale:SetAttribute("IsAnimating", true)

    UIUtil:CloseUI(UI, CLOSE_TWEENINFO, function()
        UIScale:SetAttribute("IsAnimating", false)
    end)
end

function UIServiceClient.GetUI(self: Module, uiName: string)
    return self._UIs[uiName]
end

function UIServiceClient.GetUIElement(self: Module, uiName: string, elementName: string): GuiObject
    return self._UIElements[uiName][elementName]
end

function UIServiceClient.GetUIGroup(self: Module, uiName: string, groupName: string): { GuiObject }
    return self._UIGroups[uiName][groupName]
end

function UIServiceClient.UIReady(self: Module)
    return self._UIReady
end

function UIServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Screens = {}
    self._UIs = {}
    self._UICategories = {}
    self._UIElements = {}
    self._UIGroups = {}
    self._OpenUIs = {}
    self._UIReady = Promise.new()
end

function UIServiceClient.Start(self: Module)
    self:_RegisterInterface()
end

return UIServiceClient :: Module