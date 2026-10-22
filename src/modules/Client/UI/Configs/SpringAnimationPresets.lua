--[=[
    @class SpringAnimationPresets

    Named spring parameters for Blend.Spring(source, Speed, Damper).
    One truth for UI animation feel - components reference presets instead
    of hardcoding numbers, so the whole game tunes from here.

    Damper < 1 = bouncy, 1 = no overshoot, > 1 = slow settle.
]=]

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Module Table ] --
local SpringAnimationPresets = {
    -- Windows scaling in (slight bounce) and out (fast, no bounce).
    WindowOpen = { Speed = 35, Damper = 0.4 },
    WindowClose = { Speed = 50, Damper = 1 },

    -- Default button press shrink.
    ButtonPress = { Speed = 35, Damper = 0.35 },

    -- Toolbar slot press/equip scale (softer bounce than ButtonPress).
    SlotPress = { Speed = 30, Damper = 0.55 },

    -- Elements sliding between anchored positions (merchant tab bars).
    Slide = { Speed = 20, Damper = 1 },
    SlideBouncy = { Speed = 20, Damper = 0.8 },

    -- World highlight fade in/out.
    WorldFade = { Speed = 10, Damper = 1.5 },
}

-- [ Types ] --
export type SpringAnimationPreset = {
    Speed: number,
    Damper: number,
}

export type Module = typeof(SpringAnimationPresets)

return SpringAnimationPresets :: Module
