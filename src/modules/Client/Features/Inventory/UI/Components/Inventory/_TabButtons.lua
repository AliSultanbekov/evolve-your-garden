--[=[
    @class TabButtons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")
local InventoryConfigClient = require("InventoryConfigClient")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function Button(props: ButtonProps)
    local TabName = props.TabName

    return GenericButtonComponent({
        Name = "TabButton";
        Size = UDim2.fromOffset(154, 78);
        BackgroundTransparency = 1;
        Image = "rbxassetid://119559485193173";
        OnPressed = function()
            props.SwitchTab(TabName)
        end,
        Children = {
            Blend.New "TextLabel" {
                Name = "Name";
                Position = UDim2.fromOffset(44, 21);
                Size = UDim2.fromOffset(93, 36);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = TabName;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 18;
                TextWrapped = true;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(115, 36, 36);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 3;
                };
            }
        }
    });
end

-- [ Module Table ] --
local TabButtons = function(props: Props)
    local Children = {}

    for category, _ in InventoryConfigClient.TabsConfig do
        table.insert(Children, Button({
            TabName = category,
            ActiveTab = props.ActiveTab,
            SwitchTab = props.SwitchTab
        }))
    end

    return Blend.New "Frame" {
        Name = "TabButtons";
        Position = UDim2.fromOffset(5, 102);
        Size = UDim2.fromOffset(137, 328);
        BackgroundTransparency = 1;
        ZIndex = -1;
        Blend.New "UIListLayout" {
            Padding = UDim.new(0, 5);
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            SortOrder = Enum.SortOrder.Name;
        };
        Children
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    SwitchTab: (tabName: string) -> (),
}
type ButtonProps = {
    TabName: string,
    ActiveTab: ComponentTypes.Prop<string>,
    SwitchTab: (tabName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(TabButtons) & ModuleData

return TabButtons :: Module