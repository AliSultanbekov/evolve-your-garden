--[=[
    @class VFXUtil
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local VFXClass = require("VFXClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VFXUtil = {}

-- [ Types ] --
type ContainerType = "Attachment" | "BasePart"

type ModuleData = {}

export type Module = typeof(VFXUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function VFXUtil.CreateVFXInfo(
    self: Module,
    path: string,
    tags: { string }?,
    vfxId: VFXClass.VFXId?
): VFXClass.VFXInfo
    local Tags = {}

    for _, tag in (tags or {}) :: { string } do
        Tags[tag] = true
    end

    return {
        VFXId = vfxId or HttpService:GenerateGUID(false),
        Path = path,
        Tags = Tags,
    }
end

function VFXUtil.AttachmentToVFXContainer(
    self: Module, 
    name: string,
    parent: any, 
    attachment: Attachment
)
    return self:CreateAttachmentVFXContainer(name, parent, attachment.WorldCFrame)
end

function VFXUtil.BasePartToVFXContainer(
    self: Module, 
    name: string,
    parent: any, 
    basePart: BasePart
)
    return self:CreatePartVFXContainer(name, parent, basePart.CFrame, basePart.Size)
end

function VFXUtil.CreateAttachmentVFXContainer(
    self: Module,
    name: string,
    parent: any,
    cFrame: CFrame
)
    local Attachment = Instance.new("Attachment")
    Attachment.Name = name
    Attachment.WorldCFrame = cFrame
    Attachment.Parent = parent

    return Attachment
end

function VFXUtil.CreatePartVFXContainer(
    self: Module,
    name: string,
    parent: any,
    cFrame: CFrame,
    Size: Vector3
)
    local Part = Instance.new("Part")
    Part.Name = name
    Part.CFrame = cFrame
    Part.Size = Size
    Part.Transparency = 1
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanQuery = false
    Part.CanTouch = false
    Part.Parent = parent

    return Part
end

return VFXUtil :: Module