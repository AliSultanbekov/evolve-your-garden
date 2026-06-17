--[=[
    @class Tooltip
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local ItemUtil = require("ItemUtil")
local ReactiveItemUtil = require("ReactiveItemUtil")

-- [ Components ] --
local TooltipWindow = require(script.Parent.Parent.Components.Tooltip._Window)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    IsOpen = true,
    IsSelected = false,
}

-- [ Module Table ] --
local Tooltip = {
    summary = "Tooltip window showing item name, rarity, and icon",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()

        local Item = ReactiveItemUtil:ToReactive(ItemUtil:ProcessRawItem({
            Name = "Snow Blossom",
            Category = "Plant"
        }))

        local SelectedItem = ValueObject.new(if props.controls.IsOpen then Item else nil)
        local IsSelected = ValueObject.new(props.controls.IsSelected)
        local SelectedPosition = ValueObject.new(UDim2.fromScale(0.5, 0.5) :: UDim2?)

        MaidObject:Add(props.subscribe(controls, function(newControls)
            SelectedItem.Value = if newControls.IsOpen then Item else nil
            IsSelected.Value = newControls.IsSelected
        end))

        MaidObject:Add(Blend.mount(props.target, {
            TooltipWindow({
                Item = SelectedItem:Observe(),
                Position = SelectedPosition:Observe(),
                IsSelected = IsSelected:Observe(),
                OnClose = function()
                    SelectedItem.Value = nil
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

export type Module = typeof(Tooltip) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Tooltip :: Module