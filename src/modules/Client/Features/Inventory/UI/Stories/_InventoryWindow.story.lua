--[=[
    @class InventoryWindowStory
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

-- [ Components ] --
local WindowComponent = require(script.Parent.Parent.Components.InventoryWindow._WindowComponent)
local InventoryConfig = require(script.Parent.Parent.Parent._InventoryConfig)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    IsOpen = false
}

-- [ Module Table ] --
local InventoryWindowStory = {
    summary = "Summary",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local Items = ObservableMap.new()
        local ActiveTab = ValueObject.new("Garden")

        Items:Set("1", ItemUtil:ProcessRawItem({
            Name = "Snow Blossom Fruit",
            Category = "Material",
            Amount = 500000,
        }))

        Items:Set("2", ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant",
        }))

        Items:Set("3", ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant",
        }))

        Items:Set("4", ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant",
        }))

        MaidObject:Add(props.subscribe(function(values, infos)
            if infos.IsOpen.__new ~= infos.IsOpen.__old then
                IsOpen.Value = values.IsOpen
            end
        end))

        MaidObject:Add(Blend.mount(props.target, {
            WindowComponent({
                IsOpen = IsOpen:Observe(),
                Items = Items,
                ActiveTab = ActiveTab:Observe(),
                TabsConfig = InventoryConfig.TabsConfig,

                OnClose = function()
                    IsOpen.Value = false
                end,
                OnTabSwitched = function(tabName: string)
                    if tabName == ActiveTab.Value then
                        return
                    end

                    ActiveTab.Value = tabName
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

export type Module = typeof(InventoryWindowStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryWindowStory :: Module