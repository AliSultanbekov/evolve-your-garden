--[=[
    @class ButtonsStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")

-- [ Components ] --
local ButtonsWindow = require(script.Parent.Parent.Components.Buttons._ButtonsWindow)

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    
}

-- [ Module Table ] --
local ButtonsStory = {
    summary = "Summary",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)

        MaidObject:Add(Blend.mount(props.target, {
            ButtonsWindow({
                IsOpen = IsOpen:Observe(),
                OnToggleUI = function()
                    print("hi")
                end
            })
        }))

        return function()
            MaidObject:Destroy()
        end
    end
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ButtonsStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ButtonsStory :: Module