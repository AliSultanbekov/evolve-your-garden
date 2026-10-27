--[=[
    @class VFXClass
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VFXClass = {}
VFXClass.__index = VFXClass

-- [ Types ] --
export type QueryType = "Tag" | "Id"
export type VFXId = string
export type VFXInfo = {
    VFXId: VFXId,
    Path: string,
    Tags: {
        [string]: boolean
    },
}
export type Props = {
    Container: BasePart | Attachment,
    VFXInfos: {
        [VFXId]: VFXInfo
    }
}
export type ObjectData = {
    _Container: BasePart | Attachment,
    _VFXInfos: {
        [VFXId]: VFXInfo
    },
    _TagToVFXIds: {
        [string]: {
            [VFXId]: boolean
        }
    },
    _VFXIdToParticles: {
        [VFXId]: {
            [string]: ParticleEmitter
        }
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, VFXClass))
export type Module = typeof(VFXClass)

-- [ Private Functions ] --
local function ScaleParticle(particle: ParticleEmitter, scale: number)
    local Keypoints = {}

    for _, keypoint in particle.Size.Keypoints do
        table.insert(Keypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope * scale))
    end

    particle.Size = NumberSequence.new(Keypoints)
    particle.Speed = NumberRange.new(particle.Speed.Min * scale, particle.Speed.Max * scale)
    particle.Acceleration *= scale
end

function VFXClass._GetScale(self: Object, particle: ParticleEmitter): number?
    local ReferenceSize = particle:GetAttribute("ReferenceSize") :: Vector3?

    if not ReferenceSize then
        return nil
    end

    if not self._Container:IsA("BasePart") then
        return nil
    end

    -- ScaleExponent softens how much the VFX follows the container: 0.5 means a
    -- container twice as big gets a VFX about 1.4x as big. Without it, scale is exact.
    local ScaleExponent = (particle:GetAttribute("ScaleExponent") :: number?) or 1

    return (self._Container.Size.Magnitude / ReferenceSize.Magnitude) ^ ScaleExponent
end

function VFXClass._ExtractParticlesFromPath(self: Object, path: string)
    local Folder = AssetProvider:Get("VFX/" .. path) :: Folder?

    if not Folder then
        warn(`[VFXClass] No VFX folder at '{path}'`)
        return {}
    end

    local Particles = {}

    for _, particle in Folder:GetChildren() do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        local Scale = self:_GetScale(particle)

        if Scale then
            ScaleParticle(particle, Scale)
        end

        particle.Enabled = false
        particle.Parent = self._Container

        Particles[particle.Name] = particle
    end

    Folder:Destroy()

    return Particles
end

function VFXClass._SetupVFXIdToParticles(self: Object)
    local VFXIdToParticles = {}

    for _, vfxInfo in self._VFXInfos do
        VFXIdToParticles[vfxInfo.VFXId] = self:_ExtractParticlesFromPath(vfxInfo.Path)
    end

    return VFXIdToParticles
end

function VFXClass._GetVFXIds(self: Object, queryType: QueryType, query: string): { [VFXId]: boolean }
    if queryType == "Id" then
        return { [query] = true }
    end

    return self._TagToVFXIds[query] or {}
end

function VFXClass._SetupTagToVFXIds(self: Object)
    local TagToVFXIds = {}

    for _, vfxInfo in self._VFXInfos do
        for tag, _ in vfxInfo.Tags do
            if not TagToVFXIds[tag] then
                TagToVFXIds[tag] = {}
            end

            TagToVFXIds[tag][vfxInfo.VFXId] = true
        end
    end

    return TagToVFXIds
end

-- [ Public Functions ] --
function VFXClass.new(props: Props): Object
    local self = setmetatable({} :: any, VFXClass) :: Object

    self._Container = props.Container
    self._VFXInfos = props.VFXInfos
    self._TagToVFXIds = self:_SetupTagToVFXIds()
    self._VFXIdToParticles = self:_SetupVFXIdToParticles()

    return self
end

function VFXClass.Emit(self: Object, queryType: QueryType, query: string)
    for vfxId, _ in self:_GetVFXIds(queryType, query) do
        local Particles = self._VFXIdToParticles[vfxId]

        if not Particles then
            continue
        end

        for _, particle in Particles do
            local EmitCount = particle:GetAttribute("EmitCount") :: number?

            if not EmitCount then
                warn(`[VFXClass] '{particle.Name}' in VFX '{vfxId}' has no EmitCount attribute`)
                continue
            end

            particle:Emit(EmitCount)
        end
    end
end

function VFXClass.Destroy(self: Object)
    self._Container:Destroy()

    for _, particles in self._VFXIdToParticles do
        for _, particle in particles do
            particle:Destroy()
        end
    end

    table.clear(self._VFXIdToParticles)
end

return VFXClass :: Module