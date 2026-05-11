--[=[
    @class ChanceClass
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ChanceClass = {}
ChanceClass.__index = ChanceClass

-- [ Types ] --
type ChancePool<K> = { [K]: number }
export type ObjectData<K> = {
    _Luck: number,
    _LuckAffectedChances: number,
    _ChancePool: ChancePool<K>,
    _WeightPool: {[K]: number},
    _TotalWeight: number,
}
export type Object<K> = typeof(setmetatable({} :: ObjectData<K>, ChanceClass))
export type Module = typeof(ChanceClass)

-- [ Private Functions ] --
function ChanceClass._UpdateWeights<K>(self: Object<K>, chancePool: ChancePool<K>)
    local function GetDecimalCount(num: number): number
        local s = tostring(num)
        local dotIndex = string.find(s, "%.")
        if not dotIndex then return 0 end
        return #s - dotIndex
    end

    local UpdatesWeights = {}
    local TotalWeight = 0
    local Multiplier = 0

    for _, chance in chancePool do
        local DecimalCount = GetDecimalCount(chance)
        if Multiplier == 0 or Multiplier < DecimalCount then
            Multiplier = DecimalCount
        end
    end

    for key, chance in chancePool do
        local Weight = chance * math.pow(10, math.max(1, Multiplier))
        UpdatesWeights[key] = Weight
        TotalWeight += Weight
    end

    self._WeightPool = UpdatesWeights
    self._TotalWeight = TotalWeight
end

function ChanceClass._UpdateChances<K>(self: Object<K>, chancePool: ChancePool<K>)
    local UpdatedChances = {}
    local DynamicChances = {}
    local StaticChances = {}
    local TotalChance = 0
    local TotalDynamicChance = 0

    for key, chance in chancePool do
        if chance <= self._LuckAffectedChances then
            local NewChance = chance * self._Luck
            UpdatedChances[key] = NewChance
            DynamicChances[key] = NewChance
            TotalChance += NewChance
            TotalDynamicChance += NewChance
        else
            UpdatedChances[key] = chance
            StaticChances[key] = chance
            TotalChance += chance
        end
    end

    local Remainder = 100 - TotalChance

    for key, chance in DynamicChances do
        local Ratio = chance / TotalDynamicChance
        local NewChance = chance + (Remainder * Ratio)
        UpdatedChances[key] = NewChance
    end

    self._ChancePool = UpdatedChances
end

-- [ Public Functions ] --
function ChanceClass.new<K>(chancePool: { [K]: number }, _luck: number?, luckAffectedChances: number?): Object<K>
    local self = setmetatable({} :: any, ChanceClass) :: Object<K>

    self._Luck = 1
    self._LuckAffectedChances = luckAffectedChances or 10
    self._ChancePool = {}
    self._WeightPool = {}
    self._TotalWeight = 0

    self:_UpdateChances(chancePool)
    self:_UpdateWeights(self._ChancePool)

    return self
end

function ChanceClass.GetChance<K>(self: Object<K>, key: K)
    return self._ChancePool[key]
end

function ChanceClass.Choose<K>(self: Object<K>): K
    local RandomNumber = math.random(1, self._TotalWeight)
    local WeightProgress = 0

    for key, weight in self._WeightPool do
        WeightProgress += weight

        if RandomNumber <= WeightProgress then
            return key
        end
    end

    error("Failed to choose a key: no valid key found in WeightPool.")
end

return ChanceClass :: Module