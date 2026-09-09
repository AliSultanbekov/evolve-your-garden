--[=[
    @class ImagesConfig

    Central lookup for feature-scoped image sets (rarity plates, banners,
    glows). Scoped by feature, then by what the images are — keep container
    names plural and drop the feature name from inner keys (the scope
    already says it).
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ImagesConfig = {
    PlantHarvest = {
        RarityImages = {
            Celestial = "rbxassetid://72726144214075",
            Mythic = "rbxassetid://128006382351157",
            Legendary = "rbxassetid://85278657597693",
            Epic = "rbxassetid://115276544371467",
            Rare = "rbxassetid://130541742731585",
            Uncommon = "rbxassetid://91849170946744",
            Common = "rbxassetid://125015844024414",
        }
    },
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
        Banners = {
            Normal = "rbxassetid://98894193619155",
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
        RarityGlows = {
            Celestial = "rbxassetid://123145782646136",
            Mythic = "rbxassetid://76170367246352",
            Legendary = "rbxassetid://130389065348663",
        }
    },
    Encyclopedia = {
        PlantCardBackgrounds = {
            Celestial = "rbxassetid://108558146289194",
            Mythic = "rbxassetid://81360572848461",
            Legendary = "rbxassetid://84811772927740",
            Epic = "rbxassetid://109498357757740",
            Rare = "rbxassetid://127329397290249",
            Uncommon = "rbxassetid://120166528728314",
            Common = "rbxassetid://135846616087477",
            Undiscovered = "rbxassetid://130038073528754"
        }
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ImagesConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ImagesConfig :: Module
