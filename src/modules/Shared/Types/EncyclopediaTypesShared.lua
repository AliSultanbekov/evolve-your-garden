--[=[
    @class EncyclopediaTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Encyclopedia = {
    DiscoveredItems: {
        [string]: DiscoveredItem
    },
}

export type DiscoveredItem = {
    DiscoveredTime: number, -- unix timestamp (DateTime.now().UnixTimestamp)
    TotalAcquired: number,   -- lifetime count, keeps ticking after discovery
}

export type GetDiscoveredItemsRemotePacket = {
    DiscoveredItems: {
        [string]: DiscoveredItem
    },
}

return nil