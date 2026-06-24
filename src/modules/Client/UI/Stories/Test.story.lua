--[=[
    @class TestStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local HyperText = require("HyperText")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    
}

-- [ Module Table ] --
local TestStory = {
    summary = "Summary",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()

        MaidObject:Add(Blend.mount(props.target, {
            Blend.New "Frame" {
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(300, 300),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                [Blend.Instance] = function(instance: Frame)
                    local MarkUp = HyperText.newMarkup()
                    MarkUp.anim = "wiggle"
                    MarkUp.font = "rbxasset://fonts/families/Montserrat.json"
                    MarkUp.weight = Enum.FontWeight.Heavy
                    MarkUp.size = 30
                    MarkUp.color = Color3.fromRGB(255, 255, 255)
                    MarkUp.italic = true
                    MarkUp.stroke = true

                    local Attrs = HyperText.newAttributes()
                    Attrs.anim.dur = .1
                    Attrs.shake.loop = true
                    Attrs.stroke = {
                        color = Color3.new(0.129412, 0.239216, 0.376471),
                        thickness = 3,
                    }

                    local Obj = HyperText.new(instance, MarkUp, Attrs)
                    local KRAWL_MARKUP = "<weight=ExtraBold><color=red><shake=true>Krawl</weight></color></shake>"
                    local Text = "But a big commotion woke me up.<wait=.7> When I peeked out the window,<wait=.7> the village square was already teaming with " .. KRAWL_MARKUP .. "."
                    Obj:Render(Text)
                end
            }
        }))
        

        return function()
            MaidObject:Destroy()
        end
    end
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TestStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return TestStory :: Module