--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Rx = require("Rx")
local Observable = require("Observable")
local NPCTypesShared = require("NPCTypesShared")

-- [ Components ] --
local BillboardComponent = require("BillboardComponent")
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local ResponseCard = require(script.Parent._ResponseCard)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Window = function(props: Props)
    local ResponseCards = Blend.ComputedPairs((props.Topic :: any):Pipe({ Rx.map(function(topic: NPCTypesShared.Topic) return topic.Responses end) }), function(_, response: NPCTypesShared.Response)
        return ResponseCard({
            Response = response,
            ChooseResponse = props.ChooseResponse,
        })
    end)

    return BillboardComponent({
        Adornee = props.Adornee,
        ReferenceDepth = 30,
        MinScale = 0,
        MaxScale = 1.5,
        Offset = Vector3.new(-2, 0, 0),
        Children = {
            AnimatedFrameComponent({
                IsOpen = props.IsOpen,
                Name = "DialogResponses";
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromOffset(303, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                Children = {
                    ResponseCards
                }
            })
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    Adornee: Observable.Observable<Instance?>,
    Topic: Observable.Observable<NPCTypesShared.Topic>,
    ChooseResponse: (response: NPCTypesShared.Response) -> (),
}
type ModuleData = {}

export type Module = typeof(Window) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Window :: Module