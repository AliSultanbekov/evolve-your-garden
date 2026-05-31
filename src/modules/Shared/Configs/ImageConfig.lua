--[=[
    @class ImageConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ImageConfig = {
    RarityImages = {
        Celestial = "rbxassetid://114970135748413",
        Mythic = "rbxassetid://137412519941453",
        Legendary = "rbxassetid://72450687785627",
        Epic = "rbxassetid://135324057133253",
        Rare = "rbxassetid://89167135237374",
        Uncommon = "rbxassetid://118493569296859",
        Common = "rbxassetid://109018260063077",
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ImageConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ImageConfig :: Module