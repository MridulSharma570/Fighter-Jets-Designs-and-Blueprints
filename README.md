# Fighter Jets Designs and Blueprints (`Sky Dominion` — Godot 4.7)

Complete fighter-jet combat project for **Godot Engine v4.7** (Forward+ / Jolt Physics / GDScript 2.0) paired with a self-contained **Interactive 360° Hangar & Blueprint HUD Showcase** (`fighter_blueprint_hud.html`).

## Contents

- **`fighter_blueprint_hud.html`** — Zero-dependency standalone HTML5/WebGL2 showcase featuring:
  - **360° Free Hangar (WebGL2 ACES PBR)**: Unlimited orbit & zoom (top, belly, nose-on, rear exhaust, side, 3/4 hero), realistic multi-part airframes, 24K gold canopies, titanium exhausts, and real-world camos.
  - **360° X-Ray Internals**: Volumetric glass hull with color-coded internal subsystems (AESA radar, cockpit/ejection bus, rotary cannon, fuel cells, weapons bay, turbofans) and projected callouts.
  - **Studio Renders & Classified Cutaway SVG Blueprints**: 10 high-contrast aerospace renders + F1–F12 structural station blueprints.
  - **Asymmetrical Loadouts & Level 1–20 Upgrades**: Primary & secondary missiles, cannons, rockets (non-stealth jets), flares, 7 nuclear-armed jets (`#1, #2, #3, #6, #8, #9, #10`), and real-time filtered-noise Web Audio SFX.
- **`sky_dominion_godot47/`** — Full Godot Engine v4.7 project (`project.godot`, `scenes/`, `scripts/`, `shaders/`, `assets/jets/`, `docs/COMPLETE_GAME_DESIGN_BLUEPRINT.md`).

## Fighter Squadron & Real-Life Top Speeds

| # | Jet | Real-Life Max Speed | Nuclear Warhead | Rocket Pods |
|---|---|---|---|---|
| 1 | **S-57 FELONIS** | 2,140 km/h (Mach 2.00) | 1× KH-102X Stealth Nuclear (250 kt) | — |
| 2 | **J-20X WYVERN** | 2,126 km/h (Mach 2.00) | 1× CJ-20X Nuclear (200 kt) | — |
| 3 | **F-22V TALON** | 2,414 km/h (Mach 2.25) | 1× B-61N Nuclear Bay (80 kt) | — |
| 4 | **F-35K THUNDER** | 1,930 km/h (Mach 1.60) | Conventional Only | — |
| 5 | **KF-21M BORAMA** | 2,200 km/h (Mach 1.81) | Conventional Only | 14× LOG-70 Guided |
| 6 | **TY-4 TEMPEST** | 2,495 km/h (Mach 2.35) | 1× STORM-N Standoff Nuclear (150 kt) | 38× CR-70 Dart |
| 7 | **S-47 BERKUT-V** | 1,717 km/h (Mach 1.65) | Conventional Only | 10× S-13X 122mm |
| 8 | **S-35X FLANKER-Z** | 2,400 km/h (Mach 2.25) | 1× KH-59N Heavy Nuclear (180 kt) | 40× S-8K 80mm |
| 9 | **RF-3R RAFALIS** | 1,912 km/h (Mach 1.80) | 1× ASMP-R Ramjet Nuclear (300 kt) | 24× SN-68 68mm |
| 10 | **S-34X FULLBACK-B** | 1,900 km/h (Mach 1.80) | 2× KH-102S Tactical Nuclear (250 kt) | 80× S-8K 80mm |

## Quick Start

1. **Browser Showcase**: Open `fighter_blueprint_hud.html` directly in any modern WebGL2 browser.
2. **Godot Engine v4.7**: Import `sky_dominion_godot47/project.godot` in Godot 4.7+ and run `scenes/main_flight_arena.tscn`.
