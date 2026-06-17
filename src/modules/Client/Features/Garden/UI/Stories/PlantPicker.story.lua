--[=[
    @class PlantPickerStory
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
local PlantPickerWindow = require(script.Parent.Parent.Components.PlantPickerWindow._Window)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    IsOpen = true,
}

-- [ Module Table ] --
local PlantPickerStory = {
    summary = "Plant picker window for choosing a plant to place in the garden",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(props.controls.IsOpen)
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
        addItem({ Name = "Snow Blossom", Category = "Plant", Mutations = { "Juicy", "Golden", "Hardy" } })

        MaidObject:Add(props.subscribe(controls, function(newControls)
            IsOpen.Value = newControls.IsOpen
        end))

        MaidObject:Add(Blend.mount(props.target, {
            PlantPickerWindow({
                IsOpen = IsOpen:Observe(),
                Search = Search:Observe(),
                GetItems = function()
                    return Items :: any
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
                OnSearch = function(text: string)
                    Search.Value = text
                end,
                OnClose = function()
                    IsOpen.Value = false
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

export type Module = typeof(PlantPickerStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantPickerStory :: Module
