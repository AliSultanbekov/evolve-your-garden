--[=[
    @class UIServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local UITypesClient = require("UITypesClient")
local Rx = require("Rx")
local Blend = require("Blend")
local Brio = require("Brio")
local RxCollectionServiceUtils = require("RxCollectionServiceUtils")

-- [ Constants ] --
local SCREEN_TAG = "Screen"

-- [ Variables ] --

-- [ Module Table ] --
local UIServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIInfos: { [string]: UITypesClient.UIInfo },
    _UIStates: { [string]: ValueObject.ValueObject<boolean> },
}

export type Module = typeof(UIServiceClient) & ModuleData

-- [ Private Functions ] --
function UIServiceClient._CloseAllConflicted(self: Module, targetUIName: string)
    local UIInfo = self._UIInfos[targetUIName]
    local Conflicts = UIInfo.Conflicts

    for uiName in self._UIStates do
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
function UIServiceClient.ObserveCategory(self: Module, category: UITypesClient.Category)
    local States = {}

    for uiName, uiInfo in self._UIInfos do
        local Category = uiInfo.Category
        local State = self._UIStates[uiName]

        if Category == category then
            table.insert(States, State:Observe())
        end
    end

    if #States == 0 then
        return Rx.of(false)
    end

    return Rx.combineLatest(States):Pipe({
        Rx.map(function(data)
            for _, isOpen in data do
                if isOpen then
                    return true
                end
            end

            return false
        end) :: any,
        Rx.distinct() :: any
    }) :: any
end

--[=[
    Observes a screen (a ScreenGui tagged "Screen") by name as a Brio. The brio
    is alive while the screen exists and dies when it is removed/untagged, so
    callers can tie mounts to its lifetime. Never yields.

    @param screenName string
    @return Observable<Brio<ScreenGui>>
]=]
function UIServiceClient.ObserveScreen(self: Module, screenName: string)
    return RxCollectionServiceUtils.observeTaggedBrio(SCREEN_TAG):Pipe({
        Rx.where(function(brio: Brio.Brio<Instance>)
            return brio:GetValue().Name == screenName
        end) :: any,
    })
end

--[=[
    Mounts a Blend tree into a screen for as long as that screen exists. `render`
    is called each time the screen appears (it must build fresh instances), and
    the mount is cleaned up automatically when the screen goes away.

    @param screenName string
    @param render (screen: ScreenGui) -> { any }
    @return Subscription
]=]
function UIServiceClient.MountToScreen(self: Module, screenName: string, render: (ScreenGui) -> { any })
    return self:ObserveScreen(screenName):Subscribe(function(brio: Brio.Brio<ScreenGui>)
        if brio:IsDead() then
            return
        end

        local maid, screen = brio:ToMaidAndValue()
        maid:Add(Blend.mount(screen, render(screen)))
    end)
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
    local Opened = ValueObject.new(false)
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
end

function UIServiceClient.Start(self: Module)

end

return UIServiceClient :: Module
