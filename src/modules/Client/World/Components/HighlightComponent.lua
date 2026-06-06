--[=[
    @class HighlightComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Observable = require("Observable")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local HighlightComponent = function(props: Props)
    local MaidObject = Maid.new()

    local Highlight = MaidObject:Add(Instance.new("Highlight"))
    Highlight.Enabled = false
    Highlight.FillColor = props.FillColor or Color3.new(1, 1, 1)
    Highlight.FillTransparency = props.FillTransparency or 0
    Highlight.OutlineColor = props.OutlineColor or Color3.new(1, 1, 1)
    Highlight.OutlineTransparency = props.OutlineTransparency or 0
    Highlight.Parent = props.Adornee
    Highlight.Adornee = props.Adornee

    MaidObject:Add(props.Enabled:Subscribe(function(enabled: boolean)
        Highlight.Enabled = enabled
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    Enabled: Observable.Observable<boolean>,
    Adornee: Instance,
    FillColor: Color3?,
    FillTransparency: number?,
    OutlineColor: Color3?,
    OutlineTransparency: number?,
}
type ModuleData = {}

export type Module = typeof(HighlightComponent) & ModuleData

return HighlightComponent :: Module