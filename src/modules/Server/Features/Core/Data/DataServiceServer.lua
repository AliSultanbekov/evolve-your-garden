--[=[
    @class DataServiceServer
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ProfileConfig = require("_ProfileConfig")
local ProfileStore = require("_ProfileStore")

local ServiceBag = require("ServiceBag")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")

-- [ Constants ] --

-- [ Variables ] --
local KEY = "V_3"
local PROFILE_TEMPLATE = ProfileConfig.Template
local PROFILE_WAIT_TIMEOUT = 60

-- [ Module Table ] --
local DataServiceServer = {}

-- [ Types ] --
type Profile = ProfileStore.Profile<ProfileConfig.ProfileTemplate>

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Profiles: { [Player]: Profile },
    _PlayerStore: ProfileStore.ProfileStore<ProfileConfig.ProfileTemplate>,
    _Leaderstats: { [Player]: { [string]: NumberValue } },
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

    Profile.OnSessionEnd:Connect(function()
        self._Profiles[player] = nil
        player:Kick("Profile session end - Please rejoin")
    end)

    if player.Parent == Players then
        self._Profiles[player] = Profile
        print(`Profile loaded for {player.DisplayName}!`)
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
