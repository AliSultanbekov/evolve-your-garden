
--[=[
    @class Pack
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local AssetProvider = require("AssetProvider")

-- [ Components ] --

-- [ Constants ] --
local PACK_SIZE_X = 1.8
local PACK_PADDING_X = 1
local PACK_ROTATION = 20
local PACK_Z_OFFSET = 0.5

-- [ Variables ] --
local Camera = workspace.CurrentCamera

-- [ Functions ] --
local function SetupPackModel(packName: string): Model
    local PackModel = AssetProvider:Get("Objects/Items/" .. packName) :: Model
    PackModel.Parent = workspace
    PackModel:PivotTo(CFrame.new())

    return PackModel
end

-- [ Module Table ] --
local Pack = function(props: Props)
    local MaidObject = Maid.new()
    local PackModel = MaidObject:Add(SetupPackModel(props.PackName))

    local TotalPacks = props.TotalPacks
    local PackNumber = props.PackNumber
    local Spacing  = PACK_SIZE_X + PACK_PADDING_X

    local Index = PackNumber - 1
    local Center = (TotalPacks - 1) / 2
    local DistanceFromCenter = Index - Center
    local XOffset = DistanceFromCenter * Spacing
    local YRotation = DistanceFromCenter * PACK_ROTATION
    local ZOffset = math.abs(DistanceFromCenter * PACK_Z_OFFSET)
    
    RunService:BindToRenderStep("PackAnim", Enum.RenderPriority.Camera.Value + 1, function(dt)
        PackModel:PivotTo(Camera.CFrame * CFrame.new(XOffset, 0, -8 + ZOffset) * CFrame.Angles(0, math.rad(-YRotation), 0))
    end)

    MaidObject:Add(function()
        RunService:UnbindFromRenderStep("PackAnim")
    end)

    return MaidObject
end

-- [ Types ] --
type Props = {
    PackName: string,
    PackNumber: number,
    TotalPacks: number
}
type ModuleData = {}

export type Module = typeof(Pack) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Pack :: Module