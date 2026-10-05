# Evolve Your Garden

A multiplayer garden-simulation game on Roblox, written in fully typed Luau. Players plant seeds, watch them grow in real time, harvest and sell crops, buy packs from a rotating shop, and build up their garden.

I'm the lead developer and sole programmer on a self-funded team (two commissioned 3D/UI specialists, a design partner and five playtesters). The codebase is about 29,000 lines across 213 modules.

## Features

| Done and playtested | In progress |
|---|---|
| Core loop: plant → grow → harvest → collect → sell | Encyclopedia (discovery tracking + UI) |
| Merchant with live stock and restock timer | Player stats |
| Pack store with weighted rolls, synced across servers | Quest system |
| Inventory with capacity, item actions and a reactive grid | |
| Weather shared across all servers | |
| Five UI windows built from Figma designs | |

Cross-server state (weather and the rotating pack-store sale) comes from a separate Java/Spring Boot service: **[EvolveYourGardenBackend](https://github.com/AliSultanbekov/EvolveYourGardenBackend)**.

## Architecture

```
src/modules/
  Server/Features/<Feature>/   authoritative services: validate, mutate, persist
  Client/Features/<Feature>/   client services, reactive state, UI and world
  Shared/                      configs, enums, types, utilities used by both
```

- **Server-authoritative.** The client only sends requests (for example "buy this pack"). The server checks everything against its own state, makes the change, and sends back the authoritative result. The client never computes prices, stock or outcomes.
- **One feature, one folder.** Each feature has a service, a network layer (its declared events and requests) and its types, on both server and client. Networking is kept separate from game logic.
- **Dependency injection.** Services are created and wired by a service container (Nevermore's `ServiceBag`), so dependencies are explicit and there are no hidden globals.
- **Persistence.** Player data is saved with ProfileStore behind a single data service; persisted field names are treated as permanent.
- **Reactive client.** Server state is mirrored into observable values (Rx), and the UI is declarative (Blend): windows update themselves when data changes instead of being redrawn by hand.

## Design principles

These are written up in full in [CONVENTIONS.md](CONVENTIONS.md). The main ones:

- **One persisted truth; everything else is derived.** Progress and percentages are computed, never stored twice.
- **Anchors, not accumulators.** Anything that grows with time (crop growth, cooldowns, playtime) stores a start time and derives elapsed time, instead of ticking every frame.
- **Choke points.** Every way of gaining an item goes through one function, which then notifies the systems that care. One writer per state change.
- **Events, never polling.** Every change happens in code, so there's always a signal to react to.

## Tools

- [Rojo](https://rojo.space/) — syncs the code into Roblox Studio
- [Aftman](https://github.com/LPGhatguy/aftman) — toolchain manager
- [Selene](https://kampfkarren.github.io/selene/) and [StyLua](https://github.com/JohnnyMorganz/StyLua) — linting and formatting
- [Nevermore](https://github.com/Quenty/NevermoreEngine) — packages (ServiceBag, Rx, Blend, Maid)
- npm — package manager

## Building

1. Run `npm install`
2. Run `rojo serve` and connect from Roblox Studio
