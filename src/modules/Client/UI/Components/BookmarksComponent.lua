--[=[
    @class BookmarksComponent

    Shared left-side bookmark rail used by every tabbed window (inventory,
    pack store, merchant, encyclopedia). Hangs off the window's left edge
    behind the background image; one AnimatedButton bookmark per tab, tinted
    white when active / grey when inactive.

    Per-tab entries can override the art, label and stroke, and inject extra
    children (e.g. the merchant's overlay plate or the encyclopedia's
    claimable-rewards badge) via a builder that receives the tab's tint
    observable so custom art can dim with the rest of the bookmark.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local AnimatedButtonComponent = require("AnimatedButtonComponent")

-- [ Constants ] --
local DEFAULT_POSITION = UDim2.fromOffset(-184, 105)
local DEFAULT_BUTTON_SIZE = UDim2.fromOffset(307, 104)
local DEFAULT_LABEL_POSITION = UDim2.fromOffset(48, 34)
local DEFAULT_LABEL_SIZE = UDim2.fromOffset(130, 38)
local DEFAULT_TEXT_SIZE = 24
local DEFAULT_STROKE_COLOR = Color3.fromRGB(106, 38, 38)
local RAIL_WIDTH = 184
local PADDING = 5

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local BookmarksComponent = function(props: Props)
    local ButtonSize = props.ButtonSize or DEFAULT_BUTTON_SIZE

    local Children = {}

    for order, tab in props.Tabs do
        local TabName = tab.Name

        local Tint = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return if activeTab == TabName then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(170, 170, 170)
        end)

        local ButtonChildren: { any } = {
            Blend.New "TextLabel" {
                Name = "Title";
                Position = tab.LabelPosition or props.LabelPosition or DEFAULT_LABEL_POSITION;
                Size = tab.LabelSize or props.LabelSize or DEFAULT_LABEL_SIZE;
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = tab.Text or TabName;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = tab.TextSize or props.TextSize or DEFAULT_TEXT_SIZE;
                TextWrapped = true;
                ZIndex = 2;
                Blend.New "UIStroke" {
                    Color = tab.StrokeColor or props.StrokeColor or DEFAULT_STROKE_COLOR;
                    Thickness = 3;
                };
            };
        }

        if tab.Children then
            for _, child in tab.Children(Tint) do
                table.insert(ButtonChildren, child)
            end
        end

        table.insert(Children, AnimatedButtonComponent({
            Name = TabName .. "Tab";
            LayoutOrder = order;
            Size = ButtonSize;
            BackgroundTransparency = 1;
            Image = tab.Image or props.Image;
            ImageColor3 = Tint;
            OnPressed = function()
                props.SwitchTab(TabName)
            end,
            Children = ButtonChildren;
        }))
    end

    local TabCount = #props.Tabs
    local RailHeight = TabCount * ButtonSize.Y.Offset + math.max(TabCount - 1, 0) * PADDING

    return Blend.New "Frame" {
        Name = "Bookmarks";
        Position = props.Position or DEFAULT_POSITION;
        Size = UDim2.fromOffset(RAIL_WIDTH, RailHeight);
        BackgroundTransparency = 1;
        Blend.New "UIListLayout" {
            Padding = UDim.new(0, PADDING);
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Top;
            SortOrder = Enum.SortOrder.LayoutOrder;
        };
        Children
    }
end

-- [ Types ] --
export type Tab = {
    Name: string,
    Text: string?,
    Image: string?,
    LabelPosition: UDim2?,
    LabelSize: UDim2?,
    TextSize: number?,
    StrokeColor: Color3?,
    Children: ((tint: any) -> { any })?,
}
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    SwitchTab: (tabName: string) -> (),
    Tabs: { Tab },

    Image: string?,
    ButtonSize: UDim2?,
    LabelPosition: UDim2?,
    LabelSize: UDim2?,
    TextSize: number?,
    StrokeColor: Color3?,
    Position: UDim2?,
}
type ModuleData = {}

export type Module = typeof(BookmarksComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return BookmarksComponent :: Module
