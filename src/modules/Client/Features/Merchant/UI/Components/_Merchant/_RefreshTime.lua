--[=[
    @class RefreshTime

    Countdown until the merchant's next stock refresh. Driven by the
    server-authoritative LastRefresh timestamp + MerchantConfig.RefreshTime.
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Rx = require("Rx")
local Observable = require("Observable")
local MerchantConfig = require("MerchantConfig")

-- [ Components ] --

-- [ Constants ] --
local ACTIVE_POSITION = UDim2.fromOffset(67, 651)
local INACTIVE_POSITION = UDim2.fromOffset(67, 550)

-- [ Variables ] --

-- [ Functions ] --
local function FormatMMSS(seconds: number): string
    return string.format("%02d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
end

-- [ Module Table ] --
local RefreshTime = function(props: Props)
    local Now = Rx.fromSignal(RunService.Heartbeat):Pipe({
        Rx.map(function()
            return DateTime.now().UnixTimestamp
        end) :: any,
        Rx.startWith({ DateTime.now().UnixTimestamp }) :: any,
        Rx.distinct() :: any,
    })

    local TimeLeft = Rx.combineLatest({
        LastRefresh = props.LastRefresh,
        Now = Now,
    }):Pipe({
        Rx.map(function(data: any)
            if not data.LastRefresh then
                return
            end

            return math.max(0, (data.LastRefresh + MerchantConfig.RefreshTime) - data.Now)
        end) :: any,
        Rx.distinct() :: any,
    })

    return Blend.New "Frame" {
        Name = "RefreshTime";
        LayoutOrder = 1;
        Position = Blend.Spring(Blend.Computed(props.ActiveTab, function(activeTab: string)
                if activeTab == "Buy" then
                    return ACTIVE_POSITION
                else
                    return INACTIVE_POSITION
                end
            end),
            20,
            0.8
        );
        Size = UDim2.fromOffset(183, 99);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 2;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://70576526383444";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "TextLabel" {
            Name = "SearchBox";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(8, 19);
            Size = UDim2.fromOffset(167, 67);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = Blend.Computed(TimeLeft, function(timeLeft: number)
                if not timeLeft then
                    return ""
                end
                
                return "Next Refresh in:   " .. tostring(FormatMMSS(timeLeft))
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 24;
            TextWrapped = true;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(97, 61, 34);
                Thickness = 3;
            };
        };
    }
end

-- [ Types ] --
type Props = {
    LastRefresh: Observable.Observable<number?>,
    ActiveTab: Observable.Observable<string>,
}
type ModuleData = {}

export type Module = typeof(RefreshTime) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return RefreshTime :: Module
