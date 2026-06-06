--[=[
    @class Tabs
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local PackStoreTypesClient = require("PackStoreTypesClient")
local RxBrioUtils = require("RxBrioUtils")
local Observable = require("Observable")
local PackStoreConfig = require("PackStoreConfig")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Components ] --
local PackCard = require(script.Parent._PackCard)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local Tab = function(props: TabProps)
    local PackCards = (props.Packs :: any):ObserveValuesBrio():Pipe({
        RxBrioUtils.where(function(pack: PackStoreTypesClient.ReactivePack)
            return pack.Category == props.TabName
        end),
        RxBrioUtils.map(function(pack: PackStoreTypesClient.ReactivePack)
            return PackCard({
                Pack = pack,
                AnimateEffects = props.AnimateEffects,
                BuyPack = props.BuyPack,
            })
        end) :: any,
    })

    return Blend.New "Frame" {
        Name = props.TabName;
        Size = UDim2.fromOffset(1079, 594);
        BackgroundTransparency = 1;
        Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return if activeTab == props.TabName then true else false
        end);
        Blend.New "CanvasGroup" {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Blend.New "ScrollingFrame" {
                Name = "Grid";
                Size = UDim2.fromScale(1, 1);
                Active = true;
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarImageColor3 = Color3.fromRGB(191, 191, 191);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Blend.New "UIListLayout" {
                    FillDirection = Enum.FillDirection.Horizontal;
                    Padding = UDim.new(0, 30);
                    SortOrder = Enum.SortOrder.Name;
                    Wraps = true;
                };
                Blend.New "UIPadding" {
                    PaddingBottom = UDim.new(0, 25);
                    PaddingLeft = UDim.new(0, 25);
                    PaddingRight = UDim.new(0, 25);
                    PaddingTop = UDim.new(0, 25);
                };
                PackCards
            };
        }
    };
end

-- [ Module Table ] --
local Tabs = function(props: Props)
    local Children = {}

    for _, category in PackStoreConfig.Categories do
        table.insert(Children, Tab({
            TabName = category,
            ActiveTab = props.ActiveTab,
            AnimateEffects = props.AnimateEffects,
            Packs = props.Packs,
            BuyPack = props.BuyPack,
        }))
    end

    return Blend.New "Frame" {
        Name = "Tabs";
        Position = UDim2.fromOffset(144, 128);
        Size = UDim2.fromOffset(1079, 594);
        BackgroundTransparency = 1;
        Children
    }
end

-- [ Types ] --
type Props = {
    Packs: PackStoreTypesClient.Packs,
    ActiveTab: Observable.Observable<string>,
    AnimateEffects: Observable.Observable<boolean>,

    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}
type TabProps = {
    TabName: string,
    ActiveTab: Observable.Observable<string>,
    AnimateEffects: Observable.Observable<boolean>,
    Packs: PackStoreTypesClient.Packs,

    BuyPack: (packId: PackStoreTypesShared.PackId) -> ()
}

type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

return Tabs :: Module