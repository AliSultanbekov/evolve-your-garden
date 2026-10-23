--[=[
    @class SpringAnimationPresets

    Named spring parameters for Blend.Spring(source, Speed, Damper).
    One truth for UI animation feel - components reference presets instead
    of hardcoding numbers, so the whole game tunes from here.

    Damper < 1 = bouncy, 1 = no overshoot, > 1 = slow settle.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SpringAnimationPresets = {}

-- [ Private Functions ] --
function SpringAnimationPresets._Init(self: Module)
    -- Windows scaling in (slight bounce) and out (fast, no bounce).
    self.WindowOpen = { Speed = 35, Damper = 0.4 }
    self.WindowClose = { Speed = 50, Damper = 1 }

    -- Default button press shrink.
    self.ButtonPress = { Speed = 35, Damper = 0.35 }

    -- Toolbar slot press/equip scale (softer bounce than ButtonPress).
    self.SlotPress = { Speed = 30, Damper = 0.55 }

    -- Elements sliding between anchored positions (merchant tab bars).
    self.Slide = { Speed = 20, Damper = 1 }
    self.SlideBouncy = { Speed = 20, Damper = 0.8 }

    -- World highlight fade in/out.
    self.WorldFade = { Speed = 10, Damper = 1.5 }
end

-- [ Public Functions ] --

-- [ Types ] --
export type SpringAnimationPreset = {
    Speed: number,
    Damper: number,
}

type ModuleData = {
    WindowOpen: SpringAnimationPreset,
    WindowClose: SpringAnimationPreset,
    ButtonPress: SpringAnimationPreset,
    SlotPress: SpringAnimationPreset,
    Slide: SpringAnimationPreset,
    SlideBouncy: SpringAnimationPreset,
    WorldFade: SpringAnimationPreset,
}

export type Module = typeof(SpringAnimationPresets) & ModuleData

(SpringAnimationPresets :: any):_Init()

return SpringAnimationPresets :: Module
