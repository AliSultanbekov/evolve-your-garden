--[=[
    @class PlantPopupWindowStory
]=]

-- [ Roblox Services ] --
local Workspace = game:GetService("Workspace")

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local GardenTypesClient = require("GardenTypesClient")

-- [ Components ] --
local PlantPopupWindow = require(script.Parent.Parent.Components.PlantPopupWindow._WindowComponent)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    IsOpen = true,
}

-- [ Module Table ] --
local PlantPopupWindowStory = {
    summary = "World-space plant popup with BillboardGui adorned to a test part",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(controls.IsOpen)
        local Adornee = ValueObject.new(nil :: GardenTypesClient.SlotModel?)

        -- spawn a test part 10 studs in front of the editor camera
        local Camera = Workspace.CurrentCamera
        local SpawnCFrame = (Camera and Camera.CFrame or CFrame.new()) * CFrame.new(0, 0, -10)

        local Part = MaidObject:Add(Instance.new("Part"))
        Part.Name = "PopupAdorneeTest"
        Part.Anchored = true
        Part.CanCollide = false
        Part.Size = Vector3.new(2, 2, 2)
        Part.CFrame = SpawnCFrame
        Part.BrickColor = BrickColor.new("Bright green")
        Part.Material = Enum.Material.SmoothPlastic
        Part.Parent = Workspace

        Adornee.Value = Part

        MaidObject:Add(props.subscribe(function(values, infos)
            if infos.IsOpen and infos.IsOpen.__new ~= infos.IsOpen.__old then
                IsOpen.Value = values.IsOpen
            end
        end))

        MaidObject:Add(Blend.mount(props.target, {
            PlantPopupWindow({
                Adornee = Adornee:Observe(),
                IsOpen = IsOpen:Observe(),
            }),
        }))

        return function()
            MaidObject:Destroy()
        end
    end,
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(PlantPopupWindowStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantPopupWindowStory :: Module
