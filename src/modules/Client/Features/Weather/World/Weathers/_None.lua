
--[=[
    @class None
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
local None = function(props: Props)
    local MaidObject = Maid.new()

    local Folder = AssetProvider:Get("Weathers/None/Skybox") :: Folder

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

export type Module = typeof(None) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return None :: Module