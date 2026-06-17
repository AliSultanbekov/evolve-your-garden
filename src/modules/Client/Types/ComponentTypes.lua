--[=[
    @class ComponentTypes

    Shared prop types for components. Blend runs every prop through
    toPropertyObservable, so any property-like prop may be a static value,
    an Observable, or a ValueObject - Prop<T> captures that contract.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Observable = require("Observable")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Prop<T> = T | any

-- [ Module Table ] --

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
