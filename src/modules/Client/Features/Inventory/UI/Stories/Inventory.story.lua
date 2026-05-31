--[=[
    @class InventoryStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local ObservableMap = require("ObservableMap")
local ItemUtil = require("ItemUtil")
local ReactiveItemUtil = require("ReactiveItemUtil")

-- [ Components ] --
local InventoryWindow = require(script.Parent.Parent.Components.Inventory._Window)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    
}

-- [ Module Table ] --
local InventoryStory = {
    summary = "Summary",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local Items = ObservableMap.new()

        -- Test plant items (Snow Blossom with varying mutations/genetics)
        Items:Set("plant_001", ReactiveItemUtil:ToReactive(ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant"
        })))
        Items:Set("plant_002", ReactiveItemUtil:ToReactive(ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant"
        })))
        Items:Set("plant_003", ReactiveItemUtil:ToReactive(ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant"
        })))
        Items:Set("material_001", ReactiveItemUtil:ToReactive(ItemUtil:ProcessRawItem({
            Name = "Snow Blossom Fruit",
            Category = "Material"
        })))

        --[[MaidObject:Add(Blend.mount(props.target, {
            InventoryWindow({
                IsOpen = IsOpen:Observe(),
                GetItems = function(filter: string?)
                    return Items
                end,
                OnItemPressed = function()
                    print("Hi")
                end
            })
        }))]]

        return function()
            MaidObject:Destroy()
        end
    end
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(InventoryStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryStory :: Module