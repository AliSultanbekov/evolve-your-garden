--[=[
    @class ChanceClass
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --
local DEFAULT_THRESHOLD = 10

-- [ Variables ] --

-- [ Module Table ] --
local ChanceClass = {}
ChanceClass.__index = ChanceClass

-- [ Types ] --
type ChancePool<T> = {
    [T]: number
}

type WeightPool<T> = {
    [T]: number
}

export type ObjectData<T> = {
    _Luck: number,
    _Threshold: number,
    _Seed: number,
    _Random: Random,
    _TotalWeight: number,
    _WeightPool: {
        [T]: number
    },
    _Order: { T }
}
export type Object<T> = typeof(setmetatable({} :: ObjectData<T>, ChanceClass))
export type Module = typeof(ChanceClass)

-- [ Private Functions ] --
function ChanceClass._ChancesToWeights<T>(self: Object<T>, chancePool: ChancePool<T>): WeightPool<T>
    local Weights = {}
    local TotalWeight = 0

    for key, chance in chancePool do
        if chance <= self._Threshold then
            chance *= self._Luck
        end

        Weights[key] = chance
        TotalWeight += chance
    end

    self._TotalWeight = TotalWeight

    return Weights
end

function ChanceClass._GenerateOrder<T>(self: Object<T>)
    local Order = {}

    for key, _ in self._WeightPool do
        table.insert(Order, key)
    end

    table.sort(Order)

    return Order
end

-- [ Public Functions ] --
function ChanceClass.new<T>(chancePool: ChancePool<T>, luck: number?, threshold: number?, seed: number?): Object<T>
    local self = setmetatable({} :: any, ChanceClass) :: Object<T>

    self._Luck = luck or 1
    self._Threshold = threshold or DEFAULT_THRESHOLD
    self._Seed = seed or Random.new():NextInteger(1, 2^53)
    self._Random = Random.new(self._Seed)
    self._TotalWeight = 0
    self._WeightPool = self:_ChancesToWeights(chancePool)
    self._Order = self:_GenerateOrder()

    return self
end

function ChanceClass.Choose<T>(self: Object<T>): T
    local RandomNumber = self._Random:NextNumber() * self._TotalWeight
    local Accumulator = 0

    for _, key in ipairs(self._Order) do
        local Weight = self._WeightPool[key]

        if Weight <= 0 then
            continue
        end

        Accumulator += Weight

        if Accumulator >= RandomNumber then
            return key
        end
    end

    return self._Order[#self._Order]
end

function ChanceClass.GetChancePool<T>(self: Object<T>): ChancePool<T>
    local ChancePool = {}

    for key, weight in self._WeightPool do
        ChancePool[key] = weight / self._TotalWeight * 100
    end

    return ChancePool
end

return ChanceClass :: Module
