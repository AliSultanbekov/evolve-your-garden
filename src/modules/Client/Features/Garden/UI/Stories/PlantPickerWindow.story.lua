--[=[
    @class PlantPickerWindow
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
local PlantPicketWindow = require(script.Parent.Parent.Components.PlantPickerWindow.PlantPickerWindow)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    
}

-- [ Module Table ] --
local PlantPickerWindow = {
    summary = "Summary",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local Items = ObservableMap.new()

        for i = 1, 50 do
            Items:Set(tostring(i), ItemUtil:ProcessRawItem({
                Name = "Snow Blossom",
                Category = "Plant",
            }))
        end

        MaidObject:Add(Blend.mount(props.target, {
            PlantPicketWindow({
                IsOpen = IsOpen:Observe(),
                Items = Items,
                
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

export type Module = typeof(PlantPickerWindow) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantPickerWindow :: Module