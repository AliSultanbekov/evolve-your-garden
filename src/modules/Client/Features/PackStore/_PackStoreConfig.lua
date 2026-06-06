--[=[
    @class PackStoreConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreConfig = {}

-- [ Private Functions ] --
function PackStoreConfig._Init(self: Module)
    self.Categories = {"Normal", "Special"}
end

-- [ Public Functions ] --

-- [ Types ] --
type Entry = {
    Name: string,
}

type ModuleData = {
    Categories: { string },
}

export type Module = typeof(PackStoreConfig) & ModuleData

(PackStoreConfig :: any):_Init()

return PackStoreConfig :: Module