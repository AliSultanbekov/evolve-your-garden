--[=[
    @class AssetProvider
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AssetProvider = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(AssetProvider) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function AssetProvider.Get(_self: Module, path: string): any
    local Segments = path:split("/")
    local CurrentPath = ReplicatedStorage:FindFirstChild("Assets")

    for _, segment in Segments do
        local NewPath = CurrentPath:FindFirstChild(segment)

        if not NewPath then
            return nil
        end

        CurrentPath = NewPath
    end

    local Asset = CurrentPath:Clone()

    return Asset
end

return AssetProvider :: Module