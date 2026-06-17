--[=[
    @class BackingPool
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BackingPool = {}
BackingPool.__index = BackingPool

-- [ Types ] --
export type props = {
    Parent: GuiObject,
}
export type ObjectData = {
    _Maid: Maid.Maid,
    _Parent: GuiObject,
    _Backings: { Frame },
    _Count: number,
}
export type Object = typeof(setmetatable({} :: ObjectData, BackingPool))
export type Module = typeof(BackingPool)

-- [ Private Functions ] --

-- [ Public Functions ] --
function BackingPool.new(props: props): Object
    local self = setmetatable({} :: any, BackingPool) :: Object

    self._Maid = Maid.new()
    self._Parent = props.Parent
    self._Backings = table.create(0)
    self._Count = 0

    return self
end

function BackingPool.Populate(self: Object, amount: number)
    for i = 1, amount do
        self._Count += 1

        local Backing = Blend.New "Frame" {
            Name = "Backing";
            LayoutOrder = self._Count;
            BackgroundTransparency = 1;
            [Blend.Instance] = function(instance)
                table.insert(self._Backings, instance)
            end
        }

        self._Maid:Add(Blend.mount(self._Parent, {
            Backing
        }))
    end
end

function BackingPool.Ensure(self: Object, amount: number)
    local Delta = amount - self._Count 

    if Delta <= 0 then
        return
    end

    self:Populate(Delta)
end

function BackingPool.GetBacking(self: Object, index: number)
    return self._Backings[index]
end

function BackingPool.Destroy(self: Object)
    self._Maid:DoCleaning()
end

return BackingPool :: Module