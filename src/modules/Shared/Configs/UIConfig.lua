--[=[
    @class UIConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UIConfig = {}

-- [ Private Functions ] --
function UIConfig._Init(self: Module)
    self.Colors = {
        Primary = Color3.fromRGB(64, 179, 255),       -- main blue (panels, buttons, fills)
        Stroke = Color3.fromRGB(36, 66, 125),         -- dark blue outline
        Surface = Color3.fromRGB(30, 85, 120),        -- darker surface (progress bg, recessed elements)
        Accent = Color3.fromRGB(255, 187, 28),        -- gold/yellow (progress fill, highlights)
        Danger = Color3.fromRGB(255, 55, 59),         -- red (close, destructive actions)
        DangerStroke = Color3.fromRGB(137, 28, 28),   -- dark red outline
        Text = Color3.new(1, 1, 1),                   -- white text
    }
    self.Stroke = {
        Thickness = 4,
        Thin = 2,
    }
    self.Corner = {
        Sharp = UDim.new(0, 5),
        Default = UDim.new(0, 8),
        Soft = UDim.new(0, 18),
        Pill = UDim.new(0.5, 0),
    }
    self.Font = Font.fromEnum(Enum.Font.FredokaOne)
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Colors: {
        Primary: Color3,
        Stroke: Color3,
        Surface: Color3,
        Accent: Color3,
        Danger: Color3,
        DangerStroke: Color3,
        Text: Color3,
    },
    Stroke: {
        Thickness: number,
        Thin: number,
    },
    Corner: {
        Sharp: UDim,
        Default: UDim,
        Soft: UDim,
        Pill: UDim,
    },
    Font: Font,
}

export type Module = typeof(UIConfig) & ModuleData

(UIConfig :: any):_Init()

return UIConfig :: Module
