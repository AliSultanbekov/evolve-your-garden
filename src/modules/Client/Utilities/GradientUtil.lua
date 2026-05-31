--[=[
    @class GradientUtil
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --
local CyclicCache: { [ColorSequence]: CyclicEntry } = setmetatable({}, { __mode = "k" }) :: any

-- [ Module Table ] --
local GradientUtil = {}

-- [ Types ] --
type CyclicEntry = { kps: { { Time: number, Value: Color3 } }, count: number }
type Params = {
    BaseColorSequence: ColorSequence,
    Resolution: number,
    Width: number,
    Speed: number,
    Seed: number,
}
type ModuleData = {}

export type Module = typeof(GradientUtil) & ModuleData

-- [ Private Functions ] --
local function GetCyclicKeypoints(BaseColorSequence: ColorSequence): (CyclicEntry)
    local cached = CyclicCache[BaseColorSequence]
    if cached then
        return cached
    end

    local SrcKPs = BaseColorSequence.Keypoints
    local SrcCount = #SrcKPs
    local Scale = (SrcCount - 1) / SrcCount
    local CycKPs = table.create(SrcCount + 1)
    for j = 1, SrcCount do
        local kp = SrcKPs[j]
        CycKPs[j] = { Time = kp.Time * Scale, Value = kp.Value }
    end
    CycKPs[SrcCount + 1] = { Time = 1, Value = SrcKPs[1].Value }

    local entry: CyclicEntry = { kps = CycKPs, count = SrcCount + 1 }
    CyclicCache[BaseColorSequence] = entry
    return entry
end

-- [ Public Functions ] --
function GradientUtil.GetColorSequence(self: Module, params: Params, time: number): ColorSequence
    local BaseColorSequence = params.BaseColorSequence
    local Resolution = params.Resolution
    local Width = params.Width
    local Speed = params.Speed
    local Seed = params.Seed

    local Cyclic = GetCyclicKeypoints(BaseColorSequence)
    local CycKPs = Cyclic.kps
    local CycCount = Cyclic.count

    local Phase = (time * Speed/Width + Seed) % 1
    local Keypoints = table.create(Resolution + 1)

    for i = 0, Resolution do
        local Alpha = i / Resolution
        local Flow = ((Alpha / Width) + Phase) % 1

        local SeqIndex = 1
        while SeqIndex < (CycCount - 1) and Flow > CycKPs[SeqIndex + 1].Time do
            SeqIndex += 1
        end

        local A = CycKPs[SeqIndex]
        local B = CycKPs[SeqIndex + 1] or A

        local Range = B.Time - A.Time
        local T = if Range == 0 then 0 else (Flow - A.Time) / Range
        local Smooth = 0.5 - 0.5 * math.cos(T * math.pi)

        local C1 = A.Value
        local C2 = B.Value

        Keypoints[i + 1] = ColorSequenceKeypoint.new(Alpha, Color3.new(
            C1.R + (C2.R - C1.R) * Smooth,
            C1.G + (C2.G - C1.G) * Smooth,
            C1.B + (C2.B - C1.B) * Smooth
        ))
    end

    return ColorSequence.new(Keypoints)
end

return GradientUtil :: Module