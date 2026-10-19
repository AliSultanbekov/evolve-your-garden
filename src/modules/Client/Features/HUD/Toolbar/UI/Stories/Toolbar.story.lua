--[=[
    @class ToolbarStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local Rx = require("Rx")

-- [ Components ] --
local ToolbarComponent = require(script.Parent.Parent.Components.ToolbarComponent)

-- [ Constants ] --

-- [ Variables ] --
local controls = {}

-- [ Module Table ] --
local ToolbarStory = {
    summary = "Hotbar: three bound sample items, click a slot to equip (highlight) or toggle off. Slots 4-0 empty.",
    controls = controls,
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()
        local IsOpen = ValueObject.new(true)
        local EquippedSlotId = ValueObject.new(nil :: string?)

        -- Names must exist in the item configs (icons resolve from config).
        local SlotItems: { [string]: any } = {
            ["1"] = { Id = "sample-daisy", Name = "Daisy", Category = "Plant" },
            ["2"] = { Id = "sample-tomato", Name = "Tomato", Category = "Plant" },
            ["3"] = { Id = "Fruit", Name = "Fruit", Category = "Material" },
        }

        MaidObject:Add(Blend.mount(props.target, {
            ToolbarComponent({
                IsOpen = IsOpen:Observe(),
                ObserveSlotItem = function(slotId: string)
                    return Rx.of(SlotItems[slotId])
                end,
                ObserveEquippedSlotId = EquippedSlotId:Observe(),
                OnSlotPressed = function(slotId: string)
                    print("[Story] SlotPressed:", slotId)

                    if EquippedSlotId.Value == slotId then
                        EquippedSlotId.Value = nil
                    else
                        EquippedSlotId.Value = slotId
                    end
                end,
            })
        }))

        return function()
            MaidObject:Destroy()
        end
    end
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(ToolbarStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ToolbarStory :: Module
