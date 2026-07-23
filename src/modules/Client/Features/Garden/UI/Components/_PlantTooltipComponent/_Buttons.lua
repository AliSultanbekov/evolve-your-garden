--[=[
    @class Buttons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Components ] --
local AnimatedButtonComponent = require("AnimatedButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function PlantButtons(
    IsSelected: Observable.Observable<boolean>,
    actions: InventoryTypesClient.Actions
)
    return {
        AnimatedButtonComponent({
            Name = "Harvest";
            IsOpen = IsSelected;
            Image = "rbxassetid://97250954730348";
            Text = "Harvest";
            StrokeColor = Color3.fromRGB(14, 100, 13);
            OnPressed = function()
                actions.Harvest()
            end;
        }),
        AnimatedButtonComponent({
            Name = "Info";
            IsOpen = IsSelected;
            Image = "rbxassetid://138905656018275";
            Text = "Info";
            StrokeColor = Color3.fromRGB(115, 70, 34);
            OnPressed = function()
                -- Info action isn't implemented yet (GardenUIClient only provides
                -- Close/DigUp/Harvest) — guard so pressing doesn't error.
                if actions.Info then
                    actions.Info()
                end
            end;
        }),
        AnimatedButtonComponent({
            Name = "DigUp";
            IsOpen = IsSelected;
            Image = "rbxassetid://102732472413370";
            Text = "Dig up";
            StrokeColor = Color3.fromRGB(117, 26, 25);
            OnPressed = function()
                actions.DigUp()
            end;
        }),
    }
end

-- [ Module Table ] --
local Buttons = function(props: Props)
    return Blend.New "Frame" {
        Name = "Buttons";
        LayoutOrder = 2;
        Position = UDim2.fromOffset(0, 265);
        Size = UDim2.fromOffset(255, 0);
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1;
        Blend.New "UIGridLayout" {
            CellSize = UDim2.fromOffset(118, 48);
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        Blend.New "UIPadding" {
            PaddingTop = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 3 else 0)
            end),
            PaddingBottom = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 3    else 0)
            end),
        },
        AnimatedButtonComponent({
            Name = "Close";
            LayoutOrder = 100;
            IsOpen = props.IsSelected;
            Image = "rbxassetid://101276568553496";
            Text = "Close";
            StrokeColor = Color3.fromRGB(130, 40, 40);
            OnPressed = props.Actions.Close;
        }),
        PlantButtons(props.IsSelected, props.Actions),
    }
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
    IsSelected: Observable.Observable<boolean>,
    Actions: { [string]: (...any) -> (...any) },
}
type ModuleData = {}

export type Module = typeof(Buttons) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Buttons :: Module
