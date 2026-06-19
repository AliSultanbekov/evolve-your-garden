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
local ImagesConfig = {
    Inventory = {
        RarityImages = {
            Celestial = "rbxassetid://114970135748413",
            Mythic = "rbxassetid://137412519941453",
            Legendary = "rbxassetid://72450687785627",
            Epic = "rbxassetid://135324057133253",
            Rare = "rbxassetid://89167135237374",
            Uncommon = "rbxassetid://118493569296859",
            Common = "rbxassetid://109018260063077",
        }
    },
    PackStore = {
        Banner = {
            Normal = "rbxassetid://120388679844862",
            Special = "rbxassetid://95003231122217"
        },
        RarityImages = {
            Celestial = "rbxassetid://108558146289194",
            Mythic = "rbxassetid://81360572848461",
            Legendary = "rbxassetid://84811772927740",
            Epic = "rbxassetid://109498357757740",
            Rare = "rbxassetid://127329397290249",
            Uncommon = "rbxassetid://120166528728314",
            Common = "rbxassetid://114395085367525",
        },
        TabButton = {
            Unlocked = "rbxassetid://138967597938854",
            Locked = "rbxassetid://71232635909895",
        },
        PackCardRarityGlows = {
            Celestial = "rbxassetid://123145782646136",
            Mythic = "rbxassetid://76170367246352",
            Legendary = "rbxassetid://130389065348663",
        }
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ImagesConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ImagesConfig :: Module