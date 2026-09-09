# EvolveYourGarden Conventions

Consistency lives in **formulas, not strings**. When naming something new, don't ask
"what did I call the other one" — apply the formula and the name derives itself.
When two names feel inconsistent, find which one broke the formula and fix that one.

---

## Naming principles

1. **Name the thing, not the mechanism.** The service that owns player stats is
   `StatsService`, not `TrackStatsService` — tracking is its write path, not what it is.
   The claimed-quests set is `ClaimedRewards`, not `ClaimedPermQuests` — permanence
   belongs to the quest (config), not the record.
2. **Name the meaning, not the container.** Never `Data`, `Info`, `Entries`, `Counters`
   as the meaningful part of a name. `GetDiscoveredItems`, not `GetEncyclopediaData` —
   every getter returns "data"; say *which*.
3. **No feature prefix inside the feature's scope.** `PackStore.RarityGlows`, not
   `PackStore.PackCardRarityGlows`. `EncyclopediaService:GetDiscoveredItems`, not
   `:GetEncyclopediaDiscoveredItems`.
4. **Containers are plural.** `Banners`, `Buttons`, `RarityImages`, `Signals`.
5. **Persisted field names are forever.** Renaming a ProfileStore field orphans every
   existing profile's data. Get it right before shipping; after shipping, live with it.

## Naming formulas

| What | Formula | Examples |
|---|---|---|
| Services | `<Domain>Service<Server\|Client>` | `StatsServiceServer`, `MerchantServiceClient` |
| UI orchestrators | `<Domain>UIClient` | `InventoryUIClient` |
| Data getters | `Get<CollectionNoun>` | `GetItems`, `GetDiscoveredItems`, `GetStats` |
| Client observables | `Observe<Noun>` | `ObserveMousePosition`, `ObserveHoveredModel` |
| Replication packets | `<Noun><PastTenseVerb>` | `ItemsAdded`, `ItemsDiscovered`, `StatChanged` |
| Signals | in a public `Signals` table | `Signals.MousePressed` |
| Lookup maps | `_<Key>To<Value>` (plural value if list) | `_SlotModelToSlotInfo`, `_SourceKeyToQuestIds` |
| Private service fields | `_PascalCase` | `_Maid`, `_SelectedItem` |
| Constants | `UPPER_SNAKE_CASE` | `BAR_WIDTH`, `KNOB_TRAVEL` |
| Booleans / boolean props | `Is/Should/Has` prefix | `IsOpen`, `ShouldAnimate`, `IsSelected` |
| UI child components | `_PascalCase.lua` in feature folder | `_Bookmarks.lua`, `_PlantCard.lua` |
| Ordered config lists | array whose order IS the order | `TabOrder`, `Categories` |

## Data & persistence

- **One persisted truth; everything else derives.** Never mirror a counter into a
  second table; never persist what can be recomputed (quest progress, completion
  percentages, discovery state = count exists).
- **Anchors, not accumulators**, for anything that grows with the clock: store a
  start timestamp and derive elapsed (playtime, countdowns, cooldowns, growth).
  Heartbeat is for the clock only — and even then prefer a slow task loop + anchor.
- **Don't add a persisted field until you can name its consumer.** (`FirstDiscovered`
  passed this test; `RepeatableClaims` waits until repeatable quests exist.)
- **Counters live in `Data.Stats`** (scalar, incremented at choke points).
  **Write-once facts and structured records live in their domain's table**
  (`Encyclopedia.DiscoveredItems[name] = { FirstDiscovered, TotalAcquired }`).
- Public stat API is **increment-style** (`Track`/`IncrementStat`) — callers say what
  happened, not what the total should be. Absolute setters are internal (flushes).

## Types

- **Tagged unions** (literal discriminant field, like `Item.Category` or
  `Quest.GoalType: "Relative" | "Absolute"`) when variants are constructed whole,
  rarely mutated, and read at few sites — Luau narrows on the tag, no casts.
- **Optional fields / view-locals** when variants share a hot mutation path
  (the `StackableItem` lesson: writes through a union error; alias through a
  single-table view `local View: ItemTypes.Stackable = item`).
- Component props use `ComponentTypes.Prop<T>` when they accept value-or-observable.

## Server architecture

- **Server-authoritative everywhere.** Validate ids, amounts, requirements
  server-side; put authoritative results in packets (e.g. `Left`), never let the
  client compute them.
- **Choke points + hooks, not ownership.** Acquisition flows through
  `InventoryService.AddItems`; it *calls* `DiscoverItems` / `Track` — it doesn't
  own those domains. One writer per state transition; call it from every source.
- **A service earns its existence** by owning a profile section, a replication
  stream, or endpoints that will grow. Otherwise it's a pass-through — dissolve it.
- **Events for changes; never poll.** Every mutation happens in code, so there is
  always a signal to fire. If you're reaching for Heartbeat in a gameplay service,
  you've missed a choke point.
- **State machines get a reconciliation sweep on profile load** (re-evaluate
  transitions that events might have missed). Self-healing beats never-broken.
- **Boot-validate configs** in `_Init`: unknown ids, missing/contradictory fields
  (`Repeatable + Absolute`), bad references → `error()` at startup, loudly.

## UI

- **Offsets only** from design exports: strip plugin scale-noise (`0.000xxx` scales)
  and plugin-only/beta properties (`BorderStrokePosition` errors at runtime and kills
  sibling mounts). Meaningful scales (`fromScale(0.5, 0.5)`, `fromScale(1, 1)`) stay.
- **Share machinery, duplicate assembly.** Shared components (`Client/UI/Components`)
  own mechanism: buttons, bars, rails, tooltips-shell. Feature folders own thin
  composition (`_Bookmarks.lua` wrappers). Extract on the *third* repetition, and
  design the props contract before implementing (what varies → props with defaults;
  what's fixed → hardcoded; what's irregular → children/builder escape hatch).
- **Animations live only in `Animated*` components.** `GenericButtonComponent` is
  dumb (reports press begin/end); `AnimatedButtonComponent` owns springs.
- **`AnimatedFrameComponent` needs `IsOpen`** — nil springs scale to 0 = invisible.
- **Never scale-size children inside AutomaticSize ancestors** (layout feedback loop).
- **State layering:** written-and-read only by UI → UI client owns it; crossing
  layers (world ↔ UI, service ↔ service) → service client owns it.
- **One story per window** (UI Labs). Loader requires: `init.lua` uses
  `script.Parent.loader`; child components use
  `script:FindFirstAncestor("Components").loader`.
- Structure-only passes mark every dynamic value with `-- PLACEHOLDER:` comments;
  reactive wiring replaces them.

## Process

- Sort comparators over dictionary-sourced data should define a total order
  (tiebreaker on a second key) unless per-session shuffle is explicitly accepted.
- Fix old-style code **opportunistically** (boy-scout, while in the file for a real
  reason) — never as a dedicated rewrite campaign.
- `_`-prefixed modules are **path-required only** (`require(script._X)`), never through
  the Nevermore by-name loader. Duplicate basenames among them are therefore harmless —
  the loader's registry entry gets overwritten but nothing reads it. The
  `[PackageTracker] - Overwriting moduleScript` boot warnings this produces are known,
  accepted noise. Unprefixed modules ARE name-required and must have unique names.
