--[=[
    @class Slot

    One toolbar slot: cloud backing, bound item's icon, keybind label and
    an equipped highlight. Art is PLACEHOLDER until the real cloud assets
    land; swap the images, keep the bindings.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Rx = require("Rx")
local ItemTypes = require("ItemTypes")
local ItemConfig = require("ItemConfig")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ToolbarTypesShared = require("ToolbarTypesShared")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local AnimatedButtonComponent = require("AnimatedButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Slot = function(props: Props)
    local Item = props.ObserveItem()

    local Icon = Item:Pipe({
        Rx.map(function(item: ReactiveItemTypes.ReactiveItem?)
            if not item then
                return ""
            end

            return ItemConfig:GetIcon(item.Name, item.Category)
        end) :: any,
    })

    local IsEquipped = props.ObserveEquippedSlotId:Pipe({
        Rx.map(function(equippedSlotId: ToolbarTypesShared.SlotId?)
            return equippedSlotId == props.SlotId
        end) :: any,
    })

    return AnimatedButtonComponent({
        Name = props.SlotId;
        LayoutOrder = props.LayoutOrder;
        Size = UDim2.fromOffset(props.Size, props.Size);
        Image = "rbxassetid://110306352551009";
        ImageColor3 = Blend.Computed(IsEquipped, function(isEquipped: boolean)
            return if isEquipped then Color3.fromRGB(255, 255, 255) else Color3.new()
        end);
        ImageTransparency = Blend.Computed(IsEquipped, function(isEquipped: boolean)
            return if isEquipped then 0 else 0.6
        end);
        ScaleType = Enum.ScaleType.Fit;
        GetScale = function(isPressed)
            return Blend.Spring(
                Blend.Computed(isPressed, IsEquipped, function(pressed: boolean, isEquipped: boolean)
                    if pressed then
                        return 0.9
                    end

                    return if isEquipped then 1.1 else 1
                end),
                30,
                0.55
            )
        end;
        OnPressed = function()
            props.OnPressed(props.SlotId)
        end;
        Children = {
            Blend.New "ImageLabel" {
                Name = "Icon";
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.fromScale(0.5, 0.5);
                Size = UDim2.new(1, -24, 1, -24);
                BackgroundTransparency = 1;
                Image = Icon;
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 2;
            };
            Blend.New "TextLabel" {
                Name = "Keybind";
                Position = UDim2.fromOffset(6, 4);
                Size = UDim2.fromOffset(24, 24);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = props.SlotId;
                TextColor3 = Blend.Computed(IsEquipped, function(isEquipped: boolean)
                    return if isEquipped then Color3.fromHex("#68CEFF") else Color3.fromRGB(255, 255, 255)
                end);
                TextSize = 20;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 2;
                };
            };
        };
    })
end

-- [ Types ] --
type Props = {
    SlotId: ToolbarTypesShared.SlotId,
    LayoutOrder: number,
    Size: number,
    ObserveItem: () -> Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    ObserveEquippedSlotId: Observable.Observable<ToolbarTypesShared.SlotId?>,
    OnPressed: (slotId: ToolbarTypesShared.SlotId) -> (),
}
type ModuleData = {}

export type Module = typeof(Slot) & ModuleData

return Slot :: Module
