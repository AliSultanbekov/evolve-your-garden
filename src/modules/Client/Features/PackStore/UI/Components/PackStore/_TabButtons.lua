--[=[
    @class TabButtons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")
local PackStoreConfig = require("PackStoreConfig")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --
-- Per-tab art + title layout. Title is offset right on tabs whose art carries
-- an icon on the left. Falls back to the full-width Normal layout if a
-- category has no entry yet.
local DEFAULT_TAB = {
    Image = "rbxassetid://130800794395586",
    TitlePosition = UDim2.fromOffset(6, 6),
    TitleSize = UDim2.fromOffset(168, 48),
}
local TAB_CONFIG = {
    Normal = {
        Image = "rbxassetid://130800794395586",
        TitlePosition = UDim2.fromOffset(6, 6),
        TitleSize = UDim2.fromOffset(168, 48),
    },
    Special = {
        Image = "rbxassetid://140520092400430",
        TitlePosition = UDim2.fromOffset(64, 6),
        TitleSize = UDim2.fromOffset(110, 48),
    },
}

-- [ Variables ] --

-- [ Functions ] --
local function Button(props: ButtonProps)
    local TabName = props.TabName
    local Config = TAB_CONFIG[TabName] or DEFAULT_TAB

    return GenericButtonComponent({
        Name = TabName;
        Size = UDim2.fromOffset(180, 64);
        BackgroundTransparency = 1;
        Image = Config.Image;
        OnPressed = function()
            props.SwitchTab(TabName)
        end,
        Children = {
            Blend.New "TextLabel" {
                Name = "Title";
                Position = Config.TitlePosition;
                Size = Config.TitleSize;
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = TabName .. " Packs";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 20;
                TextWrapped = true;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(97, 61, 34);
                    Thickness = 3;
                };
            };
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
        Position = UDim2.fromOffset(4, 96);
        Size = UDim2.fromOffset(200, 608);
        BackgroundTransparency = 1;
        ZIndex = 3;
        Blend.New "UIListLayout" {
            Padding = UDim.new(0, 10);
            SortOrder = Enum.SortOrder.Name;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
        };
        Blend.New "UIPadding" {
            PaddingTop = UDim.new(0, 10);
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
