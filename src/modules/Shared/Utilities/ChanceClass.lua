--[=[
    @class ChanceClass
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

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
    _TotalChance: number,
}
export type Object<K> = typeof(setmetatable({} :: ObjectData<K>, ChanceClass))
export type Module = typeof(ChanceClass)

-- [ Private Functions ] --
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
    self._TotalChance = TotalChance
end

-- [ Public Functions ] --
function ChanceClass.new<K>(chancePool: { [K]: number }, _luck: number?, luckAffectedChances: number?): Object<K>
    local self = setmetatable({} :: any, ChanceClass) :: Object<K>

    self._Luck = 1
    self._LuckAffectedChances = luckAffectedChances or 10
    self._ChancePool = {}
    self._TotalChance = 0

    self:_UpdateChances(chancePool)

    return self
end

function ChanceClass.GetChance<K>(self: Object<K>, key: K)
    return self._ChancePool[key]
end

function ChanceClass.Choose<K>(self: Object<K>): K
    local RandomNumber = math.random() * self._TotalChance
    local ChanceProgress = 0
    
    for key, chance in self._ChancePool do
        ChanceProgress += chance

        if RandomNumber < ChanceProgress then
            return key
        end
    end

    error("Failed to choose a key: no valid key found in WeightPool.")
end

return ChanceClass :: Module