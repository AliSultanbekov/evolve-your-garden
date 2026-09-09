# Issues — Aug 2026 deep review

Working checklist from the three-agent review (+ hand-verified spot checks).
Paths relative to `src/modules/`. Tick as fixed.

## P0 — game-breaking or trivial (do before applications)

- [✅] **Bind `GetGardens`** — `Server/Features/Garden/GardenNetworkServer.lua:119` has `DeclareMethod` but no `Channel:Bind` → client fetch promise never resolves (gardens only work via `GardenClaimed` broadcasts). Add the Bind like Inventory's `GetItems`.
- [✅] **Bind `GetCurrentWeather`** — same defect, `Server/Features/Weather/WeatherNetworkServer.lua:60-66`.
- [✅] **GLOBAL pack stock aliased across profiles** (local packs are fine — built fresh per player) — `PackStoreServiceServer.lua:136-138` `Packs[pack.Id] = pack` stores the reference shared with `_CurrentSale.GlobalPacks`, so `Pack.Left -= 1` (:109) decrements for everyone in-session; after save/load the sharing breaks and rejoiners keep stale `Left` (:130 `continue`). If per-player stock intended: `table.clone(pack)`. If shared world-stock intended: keep globals out of profiles, resolve from `_CurrentSale` at buy time.
- [✅] **Pack opening destroys items on capacity fail** — `Server/Features/Inventory/InventoryServiceServer/_PackActions.lua:49-58`: packs removed, then `AddItems` may return `Fail`, result discarded. Check capacity BEFORE removing (or refund). Same ignored-`Result` pattern: `MerchantServiceServer.lua:178` (sell payout), `QuestsServiceServer.lua:95` (reward).
- [✅] **Garden level 4 = permanent server crash** — `Shared/Configs/UpgradesConfig.lua:20` `MaxLevel = 10` vs `Shared/Configs/GardenConfig.lua:21-40` stats for levels 1–3 only; consumers index unguarded (`GardenServiceServer.lua:82,144,209`). Align the configs + assert at boot.
- [✅] **Encyclopedia `discover` flag never passed** — `InventoryServiceServer/init.lua:149-151`: no caller passes `discover = true`, so `DiscoverItems` never runs and the encyclopedia stays empty. Pass `true` at every acquisition site (buy/pack/harvest); leave `RemovePlant`'s re-add as false.
- [✅] **Debug code in ship path** (HUD: label fixed; adding missing buttons still a design task):
  - [✅] `PackStoreServiceServer.lua:50-111` — `print(1)`…`print(10)` on a client-invokable endpoint
  - [✅] `MerchantUIClient.lua:192` — `OpenUI("Merchant")` force-opens shop on join
  - [✅] `Shared/Features/Core/Init/InitServiceShared.lua:89` — `print(_GetModules())` + the double scan (hoist to a local)
  - [✅] `PackStoreWorldClient.lua:41-65` — whole `Start` commented out around `print("Sssss")`
  - [✅] `HUD/.../_ButtonsWindow.lua:43-49` — button labeled "Inventory" opens Encyclopedia; no HUD route to Inventory/Merchant/PackStore
  - [✅] `DataServiceServer.lua:82` — per-join `print`
- [✅] **Quest loop bugs** (in-progress code, but real): `QuestsServiceServer.lua:61,66` `return` should be `continue`; `:56-72` never filters by `Source`/`Key` (any stat change tests every quest); `:116` passes `"Stats"` for an encyclopedia change.

## P1 — correctness & integrity

- [ ] **Luck algebraically cancels** — `Shared/Utilities/ChanceClass.lua:32-70`: redistribution divides out the luck multiplier, so all luck/genetics-driven rolls are no-ops; `0/0 → NaN` at luck 0; nothing validates pools sum to 100. Rework `_UpdateChances` + add pool validation.
- [ ] **Level curve second return wrong for lvl ≥ 3** — `Shared/Configs/Item/PlantsConfig.lua:29-41` returns previous level's COST, not cumulative start (lvl 3: returns 141, truth 191). Track prev cumulative in the loop. Also: no max-level signal at 25.
- [✅] **Zero packet validation at 6 remote endpoints** — Garden `:123,127,131`, Inventory `:89`, Merchant `:84,88`, PackStore `:78`: no nil/type guards on client packets (`Merchant.Sell:142` shows the correct pattern — apply it everywhere, or a shared guard helper).
- [ ] **Harvest cycles claimed but not produced** — `GardenServiceServer.lua:173-190`: `ClaimProductionCycles` advances the ledger for ALL cycles but only `SafeCycles` produce; XP granted for dropped cycles; cap measured in slots vs variable per-cycle amounts. Only claim what produces.
- [ ] **Portal registry grows forever** — `PortalServiceClient` `UnregisterPortal` has zero callers while registration fires per claim/level-up; destroyed models still win the per-frame closest scan. Unregister in `OnGardenDestroyed`; also `_Portal.lua:24` must NOT `Maid:Add(props.Model)` (destroys world geometry it doesn't own).
- [ ] **Merchant Buy ordering** — `MerchantServiceServer.lua:120-138`: grants item before charging, `RemoveItems` result unchecked, `Left -= 1` last; `MakeRawFromName` throws for Pack/Currency stock (`ItemUtil.lua:151-174`).
- [ ] **Packet ordering** — `InventoryServiceServer:182-198` delays Added/Updated via `task.delay(0)` while `RemoveItems:244` fires sync → buy/sell events arrive out of causal order. Make consistent.
- [✅] **Plants share config tables by reference** — `PlantsConfig.lua:57,77,96,116` (`DEFAULT_GENETICS_CONFIG`, `DEFAULT_AMOUNT_POOL`): a write to one plant mutates all. Clone per entry (or `table.freeze` everything and let writes throw).
- [ ] **`_GetItem` (live ref) vs `GetItem` (clone)** — `InventoryServiceServer:43-47/103-112`: opposite aliasing semantics, near-identical names; callers depend on clone semantics to build removal descriptors. Rename/unify.
- [✅] **Client `GardenAbandoned` leaves old slots** — `GardenServiceClient.lua:287-302` clears Owner/Level but never `Garden.Slots`; new owner inherits previous owner's slots/plants/harvest client-side.
- [✅→partial] **Maid-added-after-yield races** (Garden join now via OnDataReady — registered synchronously, cancels cleanly; DataServiceServer:250-261's own post-yield Maid:Add remains) — `DataServiceServer:250-261`, `GardenServiceServer:454-464`: player leaving during profile load skips teardown (Quenty Maid has no destroyed-guard). With `MaxGardens = 1`, one such leave bricks garden claiming for the server. Register teardown before yielding.
- [✅→partial] **`GetProfile` busy-poll on hot paths** (Merchant → 1s loop; Stats/Garden/PackStore join reads → OnDataReady; the GetProfile spin primitive itself remains for stragglers) — `DataServiceServer:114-127` (60s spin + throw); `MerchantServiceServer:214-220` calls it per player per FRAME for a 1Hz timestamp check. Use `OnDataReady`; refresh check → 1s task loop.
- [ ] **Sell amount not reset on selection change** — `MerchantUIClient:220-223`: select 99-stack, set 99, select 2-stack → amount still 99.
- [ ] **Encyclopedia UI client stubs** — `EncyclopediaUIClient`: `OnClose` empty (:69-71), `_Search` written but never passed to component, `ClaimableCount` hardcoded 0, `_DiscoveredPlantsCount` never read. (In-progress — finish the wiring.)
- [✅] **JavaBackend fragility** — no `pcall` around `RequestAsync` (:34-44 — throws on transport failure, fallbacks unreachable); `GetSecret` in `Init` (:102) can brick the entire ServiceBag boot; MessagingService `JSONDecode` unvalidated (:48-61) flows into profiles; `PackStoreServiceServer:202-228` — `BuyPack` remote connect sits BEHIND the HTTP call in `task.spawn`; connect first.
- [✅] **Mouse raycast filter empty at boot** — `MouseServiceClient:47-54,124`: if character exists at Init, exclude list is `{nil}` → pointer raycasts hit own body until respawn. Drive off `RxCharacterUtils.observeLocalPlayerCharacter()`.
- [✅] **Unvalidated UI names** — `UIZoneServiceClient:57-71` feeds raw `GetAttribute("UIName")` into `UIServiceClient:37-42` unguarded indexes; typo'd attribute throws in zone callback. Warn-and-skip instead.
- [✅] **Playtime flush teardown race** (flush now writes the captured data table via OnDataReady; DataService also fires ProfileUnloaded before dropping the profile) — `StatsServiceServer:88-102`: leave-flush calls `GetStat→GetProfile`; if Data's brio-maid cleans first, flush spins 60s and throws, losing up to a minute. Capture profile ref up front or order via `OnDataReady`.
- [ ] **error-vs-warn inconsistency** — `StatsServiceServer:45` errors / `:58` warns on same condition; `EncyclopediaServiceServer:46-57` errors on "not yet discovered" (should return 0).

## P2 — hygiene, perf, content (backlog)

- [ ] **Config boot-validation pass** (the highest-leverage single item here): assert every `ItemPool`/`BuyItems` name resolves in configs, pools sum to 100, every rarity has an image in each set, `#UpgradeStats == MaxLevel`, quest entries valid; `table.freeze` configs after `_Init`.
- [ ] Genetics: seeds overlap between adjacent `GeneticNumber`s (`PlantUtil:32-38` — use one Random stream); babies inherit parent's `GeneticNumber` verbatim (`PlantUtil:198` — every offspring is a clone); `LevelTreeChoices` never written anywhere → mutations unreachable.
- [ ] `SlotData.HarvestCount` is persisted-derived (drift risk) — recompute from `Harvest` on load like `_PlayersInventoryItemCount` (the good pattern already in Inventory).
- [ ] Growth tick: firing frame's `dt` discarded (`GardenServiceServer:468-478`); packet always non-empty so `FireAllClients` every second (:147/:196); `Players:GetChildren()` → `GetPlayers()` (:133); broadcasts full plant state to all clients.
- [ ] Snapshot-vs-event races on all four `Get*` promises (Garden/Inventory/Merchant/PackStore service clients) — buffer events until snapshot lands, or version-stamp.
- [ ] Lifecycle policy: no `Destroy` on any client service, all `Channel:Connect` handles discarded, `GardenUIClient:375-399` subscription unmaided + RenderStepped folded into combineLatest (60/s re-emits) — gate with switchMap; decide "singletons: documented" vs real teardown.
- [ ] Duplicate tooltip pipelines `MerchantUIClient:50-82` vs `InventoryUIClient:47-79` (already drifted — distinct() in one); neither shareReplays DisplayItem.
- [ ] Time/Weather: `TimeWorldClient:49` needs `%02d` (writes "6:5:3" to `Lighting.TimeOfDay`); 60 Lighting writes/s for a slow clock; dead `_Phase` computed per-Heartbeat; `WeatherWorldClient:55-57` wipes ALL of Lighting's authored children; unknown-weather warn before maid-clean leaves stale weather; hardcoded deep paths in `_Rainy`.
- [ ] NPC: nil-deref one line after nil-check (`NPCUIClient:96-103`); stale topic in shareReplay after conversation ends; hardcoded `"OpenUI_*"` dispatch if-chain; duplicated closest-object Heartbeat scan with Portal.
- [ ] `_Pack.lua:52-58` fixed `BindToRenderStep` name in per-instance component (collision when uncommented).
- [ ] Dead code to delete: `Array.lua`, `Map.lua` (has `false`-value bug anyway), `VFXClass/VFXContainer`, `GetLocalGarden`, `CheckItemExists`, `SyncLeaderstat`, Portal whitelist system, `TimeService` (unused), `InventoryTypesShared` Action/Result unions, `WeatherConfig.lua` (0 bytes), `_StatsServiceServer` dead field in Encyclopedia's ModuleData, `ObjectPool` global `ProcessKey` + nil guards.
- [ ] Content/config: Tomato has 1 growth stage (instant-grown); Snow Blossom unobtainable + `Icon = ""`; all plants produce "Snow Blossom Fruit" (copy-paste); all pack prices identical placeholder; `ProfileConfig` starts players with 5000 Coins + 5000 Gems (debug values); `Leaderstats = {}` (dead); `ProfileConfig` template's `Encyclopedia.CompletedQuests` doesn't match the type and has no reader; PackStore `Event` category half-exists; `Prices.Special` unreachable (`LocalCategories` only defines Normal); Mega Pack priced but never stocked.
- [ ] Type nits: closed string sets untyped (`Currency`, NPC `Action`); `LevelTreeChoices` declared in two places; `GrowthStages` typed as dict but used as array; mutation `Chance/CanRoll` declared with `context` but called with zero args; `GetAvaliableMutationSlotCount` typo (public API); `InitServiceShared` substring-based service discovery (unpatterned `find`, unguarded folder lookups).
