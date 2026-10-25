--[=[
    @class CommandsServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemUtil = require("ItemUtil")
local CmdrService = require("CmdrService")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CommandsServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CmdrService: CmdrService.CmdrService,
    _InventoryServiceServer: typeof(require("InventoryServiceServer"))
}

export type Module = typeof(CommandsServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CommandsServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CmdrService = self._ServiceBag:GetService(CmdrService) :: any
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
end

function CommandsServiceServer.Start(self: Module)
    self._CmdrService:RegisterCommand({
        Name = "giveitem",
        Aliases = { "give" },
        Description = "Gives a player an item",
        Group = "Admin",
        Args = {
            { Type = "player", Name = "target", Description = "Who receives it" },
            { Type = "string", Name = "itemName", Description = "Config item name" },
            { Type = "integer", Name = "amount", Description = "How many", Optional = true }
        }
    }, function(context, target: Player, itemName: string, amount: number?): string?

        local RawItem = ItemUtil:MakeRawFromName(itemName, { amount })

        if not RawItem then
            return "Unknown item: " .. itemName
        end

        self._InventoryServiceServer:AddRawItems(target, { RawItem })

        return ("Gave %s x%d to %s"):format(itemName, amount or 1, target.Name)
    end)
end

return CommandsServiceServer :: Module