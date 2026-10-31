--[=[
    @class ToolActions
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent:FindFirstAncestor("Inventory").loader).load(script) :: typeof(require)

-- [ Imports ] --
local ToolsConfig = require("ToolsConfig")
local InventoryTypesServer = require("InventoryTypesServer")
local ItemTypes = require("ItemTypes")
local GeneralTypesShared = require("GeneralTypesShared")
local GeneralEnums = require("GeneralEnums")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolActions = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ToolActions) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolActions.Use(self: Module, context: InventoryTypesServer.ItemActionContext): GeneralTypesShared.DefaultResult
    local Tool = context.Item :: ItemTypes.ToolItem
    local ToolConfig = ToolsConfig.Tools[Tool.Name]
    local Durability = Tool.Durability
    local DurabilityCost = ToolConfig.DurabilityCost or ToolsConfig.DefaultToolDurabilityCost

    if not Durability then
        return GeneralEnums.Result.Success
    end

    Tool.Durability = math.max(0, Durability - DurabilityCost)

    if Tool.Durability == 0 then
        context.Gateway.RemoveItems({
            Tool
        })
    else
        context.Gateway.UpdateItems({
            Tool
        })
    end

    return GeneralEnums.Result.Success
end

return ToolActions :: Module