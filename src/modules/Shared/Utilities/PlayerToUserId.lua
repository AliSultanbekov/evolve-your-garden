--[=[
    @class PlayerToUserId
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

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
