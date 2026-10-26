--[=[
    @class DataServiceServer
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ProfileConfig = require("ProfileConfig")
local ProfileStore = require("_ProfileStore")

local ServiceBag = require("ServiceBag")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local Signal = require("Signal")
local ReconcileUtil = require("ReconcileUtil")

-- [ Constants ] --

-- [ Variables ] --
local KEY = "BETA_V_17"
local PROFILE_TEMPLATE = ProfileConfig.Template
local PROFILE_WAIT_TIMEOUT = 60

-- [ Module Table ] --
local DataServiceServer = {}

-- [ Types ] --
type Profile = ProfileStore.Profile<ProfileConfig.ProfileTemplate>

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Profiles: { [Player]: Profile },
    _ProfileLoaded: Signal.Signal<Player>,
    _ProfileUnloaded: Signal.Signal<Player>,
    _PlayerStore: ProfileStore.ProfileStore<ProfileConfig.ProfileTemplate>,
    _Leaderstats: { [Player]: { [string]: NumberValue } },
    _SectionToTemplate: { [string]: { [any]: any } },
}

export type Module = typeof(DataServiceServer) & ModuleData

-- [ Private Functions ] --
function ResolvePath(root: any, path: string): any?
    local Current = root

    for _, segment in path:split("/") do
        if Current == nil then
            return nil
        end
        Current = Current[segment]
    end

    return Current
end

function DataServiceServer._SetupPlayerProfile(self: Module, player: Player)
    local Profile: any = self._PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if not Profile then
        player:Kick(`Profile load fail - Please rejoin`)
        return
    end

    Profile:AddUserId(player.UserId)
    Profile:Reconcile()

    -- Seed every registered section before any OnDataReady callback runs, so
    -- no service (or remote call) can ever read another's unseeded section.
    for section, template in self._SectionToTemplate do
        if Profile.Data[section] == nil then
            Profile.Data[section] = {}
        end

        ReconcileUtil:Reconcile(Profile.Data[section], template)
    end

    Profile.OnSessionEnd:Connect(function()
        -- Fire BEFORE removing the profile: unload teardowns (OnDataReady
        -- callbacks' cleanup) must still be able to resolve the profile for
        -- final reads/writes. Post-session writes are silently discarded by
        -- ProfileStore, which beats GetProfile spinning 60s and throwing.
        self._ProfileUnloaded:Fire(player)
        self._Profiles[player] = nil
        player:Kick("Profile session end - Please rejoin")
    end)

    if player.Parent == Players then
        self._Profiles[player] = Profile
        self._ProfileLoaded:Fire(player)
    else
        Profile:EndSession()
    end
end

function DataServiceServer._CreateLeaderstats(self: Module, player: Player)
    local Data = self:GetData(player)

    local LeaderstatsFolder = Instance.new("Folder")
    LeaderstatsFolder.Name = "leaderstats"
    LeaderstatsFolder.Parent = player

    for statPath, valueType in ProfileConfig.Leaderstats do
        local Splits = string.split(statPath, "/")
        local StatName = Splits[#Splits]

        local Value = Instance.new(valueType) :: any
        Value.Name = StatName
        Value.Value = ResolvePath(Data, statPath)
        Value.Parent = LeaderstatsFolder

        self._Leaderstats[player][statPath] = Value
    end
end

-- [ Public Functions ] --
-- Call from a service's Init: profiles load in Start, after every Init has run.
function DataServiceServer.RegisterTemplate(self: Module, section: string, template: { [any]: any })
    self._SectionToTemplate[section] = template
end

function DataServiceServer.GetData(self: Module, player: Player): ProfileConfig.ProfileTemplate
    return self:GetProfile(player).Data
end

function DataServiceServer.GetProfile(self: Module, player: Player): Profile
    local Deadline = os.clock() + PROFILE_WAIT_TIMEOUT

    while self._Profiles[player] == nil and os.clock() < Deadline do
        task.wait(0.05)
    end

    local Profile = self._Profiles[player]

    if not Profile then
        error(`[DataServiceServer] Profile not ready for {player.Name}`)
    end

    return Profile
end

-- Runs callback(data) once the player's profile is loaded (immediately if it
-- already is). Never yields. The callback may return a teardown that runs on
-- profile unload or when the returned cleanup is called (Maid-friendly).
function DataServiceServer.OnDataReady(
    self: Module,
    player: Player,
    callback: (data: ProfileConfig.ProfileTemplate) -> (() -> ())?
): () -> ()
    local Teardown: (() -> ())? = nil
    local LoadedConnection: any = nil
    local UnloadedConnection: any = nil
    local Fired = false

    local function RunTeardown()
        if Teardown then
            Teardown()
            Teardown = nil
        end
    end

    local function OnReady()
        if Fired then
            return
        end

        local Profile = self._Profiles[player]

        if not Profile then
            return
        end

        Fired = true

        if LoadedConnection then
            LoadedConnection:Disconnect()
            LoadedConnection = nil
        end

        Teardown = callback(Profile.Data)

        UnloadedConnection = self._ProfileUnloaded:Connect(function(unloadedPlayer: Player)
            if unloadedPlayer == player then
                RunTeardown()
            end
        end)
    end

    if self._Profiles[player] then
        OnReady()
    else
        LoadedConnection = self._ProfileLoaded:Connect(function(loadedPlayer: Player)
            if loadedPlayer == player then
                OnReady()
            end
        end)
    end

    return function()
        if LoadedConnection then
            LoadedConnection:Disconnect()
            LoadedConnection = nil
        end

        if UnloadedConnection then
            UnloadedConnection:Disconnect()
            UnloadedConnection = nil
        end

        RunTeardown()
    end
end

function DataServiceServer.SyncLeaderstat(self: Module, player: Player, statPath: string)
    local Stat = self._Leaderstats[player] and self._Leaderstats[player][statPath]

    if not Stat then
        return
    end

    local Data = self:GetData(player)
    local Value = ResolvePath(Data, statPath)

    if not Value then
        return
    end

    Stat.Value = Value
end

function DataServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Leaderstats = {}
    self._Profiles = {}
    self._SectionToTemplate = {}
    self._ProfileLoaded = Signal.new() :: any
    self._ProfileUnloaded = Signal.new() :: any
end

function DataServiceServer.Start(self: Module)
    task.spawn(function()
        self._PlayerStore = ProfileStore.New(KEY, PROFILE_TEMPLATE) :: any

        RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
            local Maid, Player = brio:ToMaidAndValue()

            self._Leaderstats[Player] = {}

            self:_SetupPlayerProfile(Player)
            self:_CreateLeaderstats(Player)

            Maid:Add(function()
                self._Leaderstats[Player] = nil

                local Profile = self._Profiles[Player]

                if Profile ~= nil then
                    Profile:EndSession()
                end
            end)
        end)
    end)
end

return DataServiceServer :: Module
