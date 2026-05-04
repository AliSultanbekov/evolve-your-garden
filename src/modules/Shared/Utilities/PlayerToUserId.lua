--[=[
    @class PlayerToUserId
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlayerToUserId = function(player: Player): string
    return tostring(player.UserId)
end

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(PlayerToUserId) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlayerToUserId :: Module
