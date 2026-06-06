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
        local ActiveTab = ValueObject.new("Garden")
        local Search = ValueObject.new("")
        local Items = ObservableMap.new()

        -- Build a reactive item from a raw item and key it by its generated Id.
        local function addItem(raw: any)
            local item = ReactiveItemUtil:ToReactive(ItemUtil:ProcessRawItem(raw))
            Items:Set(item.Id, item)
        end

        -- Plants with varying mutations
        addItem({ Name = "Snow Blossom", Category = "Plant" })
        addItem({ Name = "Snow Blossom", Category = "Plant", Mutations = { "Juicy" } })
        addItem({ Name = "Snow Blossom", Category = "Plant", Mutations = { "Golden", "Hardy" } })

        -- Material with a stack amount
        addItem({ Name = "Snow Blossom Fruit", Category = "Material", Amount = 42 })

        MaidObject:Add(Blend.mount(props.target, {
            InventoryWindow({
                IsOpen = IsOpen:Observe(),
                ActiveTab = ActiveTab:Observe(),
                Search = Search:Observe(),
                GetItems = function(_filter: string?)
                    return Items :: any
                end,
                SwitchTab = function(tabName: string)
                    ActiveTab.Value = tabName
                end,
                OnItemPressed = function(item, position)
                    print("Pressed:", item.Name, position)
                end,
                OnItemHovered = function(item, position)
                    print("Hovered:", item.Name, position)
                end,
                OnItemUnhovered = function()
                    print("Unhovered")
                end,
                OnClose = function()
                    IsOpen.Value = false
                end,
                OnSearch = function(text: string)
                    Search.Value = text
                end,
            })
        }))

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