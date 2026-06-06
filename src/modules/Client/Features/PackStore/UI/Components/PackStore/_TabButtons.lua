--[=[
    @class TabButtons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local PackStoreConfig = require("PackStoreConfig")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function Button(props: ButtonProps)
    local TabName = props.TabName

    return GenericButtonComponent({
        Name = "Normal";
        Position = UDim2.fromOffset(0, 160);
        Size = UDim2.fromOffset(210, 75);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        OnPressed = function()
            props.SwitchTab(TabName)
        end,
        Children = {
            Blend.New "ImageLabel" {
                Name = "Glow";
                Position = UDim2.fromOffset(-8, -13);
                Size = UDim2.fromOffset(231, 101);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ImageTransparency = Blend.Spring(
                    Blend.Computed(props.ActiveTab, function(activeTab: string)
                        return if activeTab == TabName then 0 else 1
                    end),
                    25
                );
                Image = "rbxassetid://105934782829660";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = -2;
            };
            Blend.New "TextLabel" {
                Name = "Name";
                Position = UDim2.fromOffset(43, 10);
                Size = UDim2.fromOffset(110, 50);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                Text = TabName;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 35;
                TextWrapped = true;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(0, 71, 97);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 4;
                };
            };
            Blend.New "ImageLabel" {
                Name = "Background";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(-4, -4);
                Size = UDim2.fromOffset(218, 83);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://138967597938854";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = -1;
            };
            --[[Blend.New "ImageLabel" {
                Name = "Lock";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(59, 9);
                Size = UDim2.fromOffset(56, 58);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://88042922627998";
                ScaleType = Enum.ScaleType.Fit;
                Visible = false;
                ZIndex = 2;
            };]]
        }
    });
end

-- [ Module Table ] --
local TabButtons = function(props: Props)
    local Children = {}

    for _, category in PackStoreConfig.Categories do
        table.insert(Children, Button({
            TabName = category,
            ActiveTab = props.ActiveTab,
            SwitchTab = props.SwitchTab
        }))
    end

    return Blend.New "Frame" {
        Name = "TabButtons";
        Position = UDim2.fromOffset(-20, 128);
        Size = UDim2.fromOffset(160, 200);
        BackgroundTransparency = 1;
        ZIndex = -3;
        Blend.New "UIListLayout" {
            Padding = UDim.new(0, 15);
            SortOrder = Enum.SortOrder.Name;
        };
        Blend.New "UIPadding" {
            PaddingTop = UDim.new(0, 25);
        };
        Children
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: Observable.Observable<string>,
    SwitchTab: (tabName: string) -> (),
}
type ButtonProps = {
    TabName: string,
    ActiveTab: Observable.Observable<string>,
    SwitchTab: (tabName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(TabButtons) & ModuleData

return TabButtons :: Module