--[=[
    @class Bookmarks

    Encyclopedia bookmark rail: Plants, Packs and Rewards. The Rewards
    bookmark uses its own (wider) art and carries a notifier badge showing
    how many quest rewards are currently claimable; it hides itself at zero.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local BookmarksComponent = require("BookmarksComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Bookmarks = function(props: Props)
    local function RewardsChildren(tint: any)
        return {
            Blend.New "ImageLabel" {
                Name = "Background";
                Position = UDim2.fromOffset(-23, 0);
                Size = UDim2.fromOffset(330, 103);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://126221906975619";
                ImageColor3 = tint;
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "Frame" {
                Name = "Notifier";
                Position = UDim2.fromOffset(19, 9);
                Size = UDim2.fromOffset(46, 46);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 3;
                Visible = Blend.Computed(props.ClaimableCount, function(count: number)
                    return count > 0
                end);
                Blend.New "ImageLabel" {
                    Name = "Background";
                    Size = UDim2.fromOffset(46, 46);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://94087883529967";
                    ScaleType = Enum.ScaleType.Fit;
                };
                Blend.New "TextLabel" {
                    Name = "Amount";
                    LayoutOrder = 1;
                    Size = UDim2.fromOffset(46, 46);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = Blend.Computed(props.ClaimableCount, function(count: number)
                        return tostring(count)
                    end);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 24;
                    TextWrapped = true;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(86, 0, 1);
                        Thickness = 2;
                    };
                };
            };
        }
    end

    return BookmarksComponent({
        ActiveTab = props.ActiveTab,
        SwitchTab = props.SwitchTab,
        Position = UDim2.fromOffset(-184, 106),
        ButtonSize = UDim2.fromOffset(307, 103),
        Image = "rbxassetid://77328027554699",
        LabelPosition = UDim2.fromOffset(50, 34),
        LabelSize = UDim2.fromOffset(117, 36),
        TextSize = 29,
        Tabs = {
            { Name = "Plants" },
            { Name = "Packs" },
            {
                Name = "Rewards",
                Image = "" :: any, -- art comes from the wider child image below
                StrokeColor = Color3.fromRGB(102, 71, 27),
                Children = RewardsChildren,
            },
        },
    })
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    ClaimableCount: Observable.Observable<number>,
    SwitchTab: (tabName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Bookmarks) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Bookmarks :: Module
