--[=[
    @class HighlightComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")
local Rx = require("Rx")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local HighlightComponent = function(props: Props)
    local TransparencyAnimation = Blend.Spring(
        Blend.Computed(props.Adornee, function(adornee)
            if adornee then
                return 0.6
            else
                return 1
            end
        end),
        10,
        1.5
    );

    local HeldAdornee = Rx.combineLatest({
        Adornee = props.Adornee,
        Transparency = TransparencyAnimation,
    }):Pipe({
        Rx.scan(function(held: Instance?, data: any): Instance?
            if data.Adornee then
                return data.Adornee
            elseif data.Transparency >= 0.99 then
                return nil
            end
            return held
        end, nil) :: any,
        Rx.distinct() :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    return Blend.New "Highlight" {
        Enabled = props.Enabled;
        FillColor = props.FillColor or Color3.new(1, 1, 1);
        FillTransparency = TransparencyAnimation;
        OutlineColor = props.OutlineColor or Color3.new(1, 1, 1);
        OutlineTransparency = TransparencyAnimation;
        Adornee = HeldAdornee
    }
end

-- [ Types ] --
type Props = {
    Enabled: ComponentTypes.Prop<boolean>,
    Adornee: ComponentTypes.Prop<Instance>,
    FillColor: ComponentTypes.Prop<Color3>?,
    FillTransparency: ComponentTypes.Prop<number>?,
    OutlineColor: ComponentTypes.Prop<Color3>?,
    OutlineTransparency: ComponentTypes.Prop<number>?,
}
type ModuleData = {}

export type Module = typeof(HighlightComponent) & ModuleData

return HighlightComponent :: Module
