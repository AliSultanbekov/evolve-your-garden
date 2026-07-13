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
                return nil
            end

            return math.max(0, (data.LastRefresh + MerchantConfig.RefreshTime) - data.Now)
        end) :: any,
        Rx.distinct() :: any,
    })

    return Blend.New "TextLabel" {
        Name = "RefreshTime";
        LayoutOrder = props.LayoutOrder;
        Position = props.Position;
        AnchorPoint = props.AnchorPoint;
        Size = props.Size;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
        Text = Blend.Computed(TimeLeft, function(timeLeft: number?)
            if not timeLeft then
                return ""
            end

            return "Restock in: " .. FormatMMSS(timeLeft)
        end);
        TextColor3 = Color3.fromRGB(255, 255, 255);
        TextSize = 24;
        ZIndex = props.ZIndex;
        Blend.New "UIStroke" {
            Color = Color3.fromRGB(43, 73, 112);
            Thickness = 3;
        };
    }
end

-- [ Types ] --
type Props = {
    LastRefresh: Observable.Observable<number?>,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Size: UDim2?,
    LayoutOrder: number?,
    ZIndex: number?,
}
type ModuleData = {}

export type Module = typeof(RefreshTime) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return RefreshTime :: Module
