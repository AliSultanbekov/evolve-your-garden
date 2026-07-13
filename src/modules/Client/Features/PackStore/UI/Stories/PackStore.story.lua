--[=[
    @class PackStoreStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")
local PackStoreTypesClient = require("PackStoreTypesClient")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Components ] --
local PackStoreWindow = require(script.Parent.Parent.Components.PackStore)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    
}

-- [ Module Table ] --
local PackStoreStory = {
    summary = "Summary",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local ActiveTab = ValueObject.new("Normal")

        local Packs = ObservableMap.new() :: PackStoreTypesClient.Packs

        local function addPack(id: string, category: PackStoreTypesShared.Category, name: string, stock: number, left: number)
            Packs:Set(id, {
                Id = id,
                Category = category,
                Name = name,
                Stock = stock,
                Left = ValueObject.new(left),
            })
        end

        -- Normal (always-available) packs
        addPack("normal_1", "Normal", "Super Pack", 5, 5)   -- full
        addPack("normal_2", "Special", "Super Pack", 5, 5)   -- full
        addPack("normal_3", "Special", "Super Pack", 5, 5)   -- full
        addPack("normal_4", "Special", "Mega Pack", 5, 5)   -- full

        MaidObject:Add(Blend.mount(props.target, {
            PackStoreWindow({
                IsOpen = IsOpen:Observe(),
                Packs = Packs,
                StartTime = ValueObject.new(DateTime.now().UnixTimestamp):Observe(),
                ActiveTab = ActiveTab:Observe(),

                SwitchTab = function(tabName: string)
                    ActiveTab.Value = tabName
                end,
                BuyPack = function(packId: PackStoreTypesShared.PackId)
                    print("[Story] BuyPack:", packId)
                end,
                OnClose = function()
                    IsOpen.Value = false
                end
            })
        }))

        return function()
            MaidObject:Destroy()
        end
    end
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(PackStoreStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PackStoreStory :: Module