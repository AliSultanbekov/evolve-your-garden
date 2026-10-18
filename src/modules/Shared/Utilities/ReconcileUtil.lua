--[=[
    @class ReconcileUtil

    Fills missing keys in a data table from a template without ever touching
    existing values - the backfill each feature service runs on its own
    profile section at the top of OnDataReady. Template tables are deep
    copied so player saves never share references with the template.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Table = require("Table")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ReconcileUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ReconcileUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ReconcileUtil.Reconcile(self: Module, target: { [string]: any }, template: { [string]: any }): { [string]: any }
    for key, value in template do
        if target[key] == nil then
            target[key] = if type(value) == "table" then Table.deepCopy(value) else value
        elseif type(target[key]) == "table" and type(value) == "table" then
            self:Reconcile(target[key], value)
        end
    end

    return target
end

return ReconcileUtil :: Module
