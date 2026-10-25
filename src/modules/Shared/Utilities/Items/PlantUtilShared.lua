--[=[
    @class PlantUtilShared

    Pure plant reads, usable on both sides: every function takes primitives
    (plantName, growthTime, geneticNumber), so plain and reactive callers
    both fit - unwrap VOs at the call site. Truth mutation lives in
    PlantUtilServer; the client mirrors, never mutates.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local PlantsConfig = require("PlantsConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantUtilShared = {}

-- [ Types ] --
export type Genetics = {
    Speed: number,
    Yield: number,
    Quality: number,
    MutationChance: number,
}

type ModuleData = {}

export type Module = typeof(PlantUtilShared) & ModuleData

-- [ Private Functions ] --
function PlantUtilShared._ScaleGenetic(self: Module, range: NumberRange, t: number): number
    return range.Min + (range.Max - range.Min) * t
end

-- [ Public Functions ] --
function PlantUtilShared.GetLastGrowthStageTime(self: Module, plantName: string): number
    local PlantConfig = PlantsConfig.Plants[plantName]
    local Stages = #PlantConfig.GrowthStages

    return PlantConfig.GrowthStages[Stages]
end

function PlantUtilShared.GetCurrentGrowthStage(self: Module, plantName: string, growthTime: number)
    local PlantConfig = PlantsConfig.Plants[plantName]
    local Stages = #PlantConfig.GrowthStages
    local CurrentStage = 0

    for i = 1, Stages do
        if PlantConfig.GrowthStages[i] <= growthTime then
            CurrentStage = i
        else
            break
        end
    end

    return CurrentStage
end

function PlantUtilShared.IsPlantFullyGrown(self: Module, plantName: string, growthTime: number)
    local PlantConfig = PlantsConfig.Plants[plantName]
    local FinalStage = #PlantConfig.GrowthStages
    local FinalStageTime = PlantConfig.GrowthStages[FinalStage]

    return FinalStageTime <= growthTime
end

function PlantUtilShared.GetActualCycleTime(self: Module, plantName: string, geneticNumber: number): number
    local PlantConfig = PlantsConfig.Plants[plantName]
    local Genetics = self:GetGenetics(plantName, geneticNumber)

    return PlantConfig.Production.CycleTime / Genetics.Speed
end

function PlantUtilShared.GetGenetics(self: Module, plantName: string, geneticNumber: number): Genetics
    local GeneticsConfig = PlantsConfig.Plants[plantName].Genetics

    return {
        Speed = self:_ScaleGenetic(GeneticsConfig.Speed, Random.new(geneticNumber + PlantsConfig.GeneticOffsets.Speed):NextNumber()),
        Yield = self:_ScaleGenetic(GeneticsConfig.Yield, Random.new(geneticNumber + PlantsConfig.GeneticOffsets.Yield):NextNumber()),
        Quality = self:_ScaleGenetic(GeneticsConfig.Quality, Random.new(geneticNumber + PlantsConfig.GeneticOffsets.Quality):NextNumber()),
        MutationChance = self:_ScaleGenetic(GeneticsConfig.MutationChance, Random.new(geneticNumber + PlantsConfig.GeneticOffsets.MutationChance):NextNumber()),
    }
end

return PlantUtilShared :: Module
