--[=[
    @class StatsTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Stats = {
    [string]: number
}

export type GetStatsRemotePacket = {
    Stats: {
        [string]: number
    }
}

export type StatUpdatedRemotePacket = {
    Stat: string,
    Value: number,
}

return nil