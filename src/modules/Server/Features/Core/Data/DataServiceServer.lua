--[=[
    @class DataServiceServer
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local ProfileStore = require("./_ProfileStore")
local ProfileConfig = require("./_ProfileConfig")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local _Maid = require("Maid")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")

-- [ Constants ] --

-- [ Variables ] --
local KEY = "V_1"
local PROFILE_TEMPLATE = ProfileConfig.Template

-- [ Module Table ] --
local DataServiceServer = {}

-- [ Types ] --
type Profile = ProfileStore.Profile<ProfileConfig.ProfileTemplate>

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Profiles: { [Player]: Profile },
    _PlayerStore: ProfileStore.ProfileStore<ProfileConfig.ProfileTemplate>,
    _Leaderstats: { [Player]: { [string]: any }}
}

export type Module = typeof(DataServiceServer) & ModuleData

-- [ Private Functions ] --
function ProcessPath(initialSegment: any, path: string, hardSet: boolean?): (boolean, any, any, any)
    local CurrentSegment = initialSegment
    local ParentSegment
    local LastSegment

    for _, segment in path:split("/") do
        if CurrentSegment[segment] ~= nil then
            ParentSegment = CurrentSegment
            LastSegment = segment
            CurrentSegment = CurrentSegment[segment]
        elseif hardSet then
            CurrentSegment[segment] = {}
            ParentSegment = CurrentSegment
            LastSegment = segment
            CurrentSegment = CurrentSegment[segment]
        else
            return false
        end
    end

    return true, CurrentSegment, ParentSegment, LastSegment
end

function DataServiceServer._SetupPlayerProfile(self: Module, player: Player)
    local Profile: any = self._PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if Profile then
        Profile:AddUserId(player.UserId)
        Profile:Reconcile()

        Profile.OnSessionEnd:Connect(function()
            self._Profiles[player] = nil
            player:Kick("Profile seasion end - Please rejoin")
        end)

        if player.Parent == Players then
            self._Profiles[player] = Profile
            print(`Profile loaded for {player.DisplayName}!`)
        else
            Profile:EndSession()
        end
    else
        player:Kick(`Profile load fail - Please rejoin`)
    end
end

function DataServiceServer._CreateLeaderstats(self: Module, player: Player)
    local LeaderstatsFolder = Instance.new("Folder")
    LeaderstatsFolder.Name = "leaderstats"
    LeaderstatsFolder.Parent = player

    for statPath, valueType in ProfileConfig.Leaderstats do
        local Splits = string.split(statPath, "/")
        local StatName = Splits[#Splits]

        local Value = Instance.new(valueType) :: any
        Value.Name = StatName
        Value.Parent = LeaderstatsFolder
        Value.Value = select(2, self:GetData(player, statPath))
        self._Leaderstats[player][statPath] = Value
    end
end

-- [ Public Functions ] --
function DataServiceServer.AddData(self: Module, player: Player, value: number, path: string): boolean
    if type(value) == "number" and (value ~= value) then
        warn("Invalid numeric value provided. Expected a number.")
        return false
    end

    local Success1, Result1 = self:GetData(player, path)

    if not Success1 then
        return false
    end

    if type(Result1) ~= "number" then
        return false
    end

    local Success2 = self:SetData(player, value + Result1, path)

    if not Success2 then
        return false
    end

    return true
end

function DataServiceServer.SetData(self: Module, player: Player, value: any, path: string, hardSet: boolean?): boolean
    if type(value) == "number" and (value ~= value) then
        warn("Invalid numeric value provided. Expected a number.")
        return false
    end

    if typeof(value) == "number" and value < 0 then
        warn("Attempted to set a negative value in DataServiceServer.SetData. Player:", player, "Path:", path, "Value:", value)
        return false
    end

    local Profile = self:GetProfile(player)

    local Success, _, ParentSegment, LastSegment = ProcessPath(Profile.Data, path, hardSet)

    if not Success then
        return false
    end

    ParentSegment[LastSegment] = value

    if self._Leaderstats[player][path] then
        self._Leaderstats[player][path].Value = value
    end

    return true
end

function DataServiceServer.UpdateData(self: Module, player: Player, cb: (data: ProfileConfig.ProfileTemplate) -> ()): boolean
    local Profile = self:GetProfile(player)

    local Success, _ = pcall(function()
        cb(Profile.Data)
    end)

    if not Success then
        return false
    end

    return true
end

function DataServiceServer.GetData(self: Module, player: Player, path: string): (boolean, any)
    local Profile = self:GetProfile(player)
    
    local Success, CurrentSegment = ProcessPath(Profile.Data, path)

    if not Success then
        return false
    end

    return true, CurrentSegment
end

function DataServiceServer.GetProfile(self: Module, player: Player): Profile
    local Deadline = os.clock() + 60

    while self._Profiles[player] == nil and os.clock() < Deadline do
        task.wait(0.05)
    end

    local Profile = self._Profiles[player]

    if not Profile then
        error(("[DataServiceServer] Profile not ready for %s"):format(player.Name))
    end

    return Profile
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
    self._PlayerStore = ProfileStore.New(KEY, PROFILE_TEMPLATE) :: any

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)  
        local _maid, Player: Player = brio:ToMaidAndValue()

        self._Leaderstats[Player] = {}

        self:_SetupPlayerProfile(Player)
        self:_CreateLeaderstats(Player)

        _maid:Add(function()
            self._Leaderstats[Player] = nil

            local profile = self._Profiles[Player]

            if profile ~= nil then
               profile:EndSession()
            end
        end)
    end)
end

return DataServiceServer :: Module