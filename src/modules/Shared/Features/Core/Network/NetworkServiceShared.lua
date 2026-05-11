local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[=[
    @class NetworkServiceShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

-- [ Module Table ] --
local NetworkServiceShared = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Channels: { [string]: Remoting.Remoting }
}

export type Module = typeof(NetworkServiceShared) & ModuleData

-- [ Private Functions ] --
function NetworkServiceShared.GetChannel(self: Module, channelName: string)
    local Channel = self._Channels[channelName]

    if not Channel then
        Channel = Remoting.new(Remotes, channelName)
        
        self._Channels[channelName] = Channel
    end

    return Channel
end

-- [ Public Functions ] --
function NetworkServiceShared.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Channels = {}
end

function NetworkServiceShared.Start(self: Module)

end

return NetworkServiceShared :: Module