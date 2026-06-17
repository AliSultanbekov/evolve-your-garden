
--[=[
    @class Rainy
]=]

-- [ Roblox Services ] --
local Lighting = game:GetService("Lighting")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local WeatherTypesClient = require("WeatherTypesClient")
local AssetProvider = require("AssetProvider")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Rainy = function(props: Props)
    local MaidObject = Maid.new()

    local Folder = AssetProvider:Get("Weathers/Rainy/Skybox") :: Folder
    local RainEffect = MaidObject:Add(AssetProvider:Get("Weathers/Rainy/RainEffect")) :: Model
    
    RainEffect.Parent = workspace
    RainEffect:PivotTo(workspace.World.Map.Props.Island.Grass:GetPivot())

    for _, instance in Folder:GetChildren() do
        MaidObject:Add(instance)
        instance.Parent = Lighting
    end

    Folder:Destroy()

    return MaidObject
end

-- [ Types ] --
type Props = WeatherTypesClient.WeatherProps
type ModuleData = {}

export type Module = typeof(Rainy) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Rainy :: Module