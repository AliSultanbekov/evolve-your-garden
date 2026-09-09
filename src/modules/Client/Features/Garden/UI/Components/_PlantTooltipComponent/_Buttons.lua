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
            Image = "rbxassetid://138166573995722";
            Text = "Harvest";
            TextSize = 22;
            StrokeColor = Color3.fromRGB(0, 105, 3);
            OnPressed = function()
                actions.Harvest()
            end;
        }),
        AnimatedButtonComponent({
            Name = "Info";
            LayoutOrder = 1;
            IsOpen = IsSelected;
            Image = "rbxassetid://134096230556407";
            Text = "Info";
            TextSize = 22;
            StrokeColor = Color3.fromRGB(109, 72, 0);
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
            LayoutOrder = 2;
            IsOpen = IsSelected;
            Image = "rbxassetid://98430497084904";
            Text = "Dig Up";
            TextSize = 22;
            StrokeColor = Color3.fromRGB(130, 40, 40);
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
        LayoutOrder = 3;
        Size = UDim2.fromOffset(255, 0);
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1;
        Blend.New "UIGridLayout" {
            CellPadding = UDim2.fromOffset(4, 4);
            CellSize = UDim2.fromOffset(119, 48);
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        Blend.New "UIPadding" {
            PaddingTop = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 3 else 0)
            end),
            PaddingBottom = Blend.Computed(props.IsSelected, function(selected: boolean)
                return UDim.new(0, if selected then 3 else 0)
            end),
        },
        AnimatedButtonComponent({
            Name = "Close";
            LayoutOrder = 100;
            IsOpen = props.IsSelected;
            Image = "rbxassetid://98430497084904";
            Text = "Close";
            TextSize = 22;
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
