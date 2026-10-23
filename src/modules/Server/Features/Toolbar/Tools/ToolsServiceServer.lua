--[=[
    @class ToolServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")
local RxPlayerUtils = require("RxPlayerUtils")
local PlayerToUserId = require("PlayerToUserId")
local Brio = require("Brio")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayersItemIdToToolState: {
        [string]: {
            [ItemTypes.ItemId]: ToolsTypesShared.ToolState
        }
    }
}

export type Module = typeof(ToolServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayersItemIdToToolState = {}
end

function ToolServiceClient.Start(self: Module)
    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()
        local UserId = PlayerToUserId(Player)

        self._PlayersItemIdToToolState[UserId] = {}

        Maid:Add(function()
            self._PlayersItemIdToToolState[UserId] = nil
        end)
    end)
end

return ToolServiceClient :: Module