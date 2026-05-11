--[=[
    @class UIScaleAnimation
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UIScaleAnimation = function(props: Props): Observable.Observable<number>
    return Blend.Spring(
        Blend.Computed(props.IsOpen, function(open: boolean)
            return if open then 1 else 0
        end)
    )
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>
}
type ModuleData = {}

export type Module = typeof(UIScaleAnimation) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return UIScaleAnimation :: Module