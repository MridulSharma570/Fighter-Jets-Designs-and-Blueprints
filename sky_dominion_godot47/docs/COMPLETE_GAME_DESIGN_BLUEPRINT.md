# SKY DOMINION — Complete Fighter Jet, Physics & Godot 4.7 Design Document

## 1. Legally Cleared Designations & Expanded Nuclear Roster (Top-3 + Middle-to-Last)
All aircraft, weapons, traits, and abilities use minimal-change original game-world names and subtle aerodynamic silhouette modifications to avoid IP/trademark conflicts. Nuclear warheads are equipped on the **Top-3** jets plus **Middle-to-Last** strike/multi-role jets (`#6`, `#8`, `#9`, `#10`).

| # | Fighter Jet | Real-Life Max Speed | Cannon | Primary Missiles | Secondary Missiles | Nuclear Warhead | Rocket Pods | Flares |
|---|---|---|---|---|---|---|---|---|
| 1 | **S-57 FELONIS** | **2,140 km/h (Mach 2.00)** | GSh-30V 30mm | 4× R-77V Adder-X | 2× R-74X Archer-II | **1× KH-102X Stealth Nuclear (250kt)** | *None (Stealth)* | 6× UV-50X |
| 2 | **J-20X WYVERN** | **2,126 km/h (Mach 2.00)** | CS-23V 23mm Pod *(Opt.)* | 6× PL-15X Dragon-BVR | *None* | **1× CJ-20X Nuclear (200kt)** | *None (Stealth)* | 5× T-935X |
| 3 | **F-22V TALON** | **2,414 km/h (Mach 2.25)** | M61V Vulcanix 20mm | 6× AM-120D Arrows | 2× AM-9X Viper | **1× B-61N Nuclear Bay (80kt)** | *None (Stealth)* | 6× MJU-39X |
| 4 | **F-35K THUNDER** | **1,930 km/h (Mach 1.60)** | GAU-22X Equalizer 25mm | 4× AM-120D Arrows | *None* | *Conventional Only* | *None (Stealth)* | 4× MJU-61X |
| 5 | **KF-21M BORAMA** | **2,200 km/h (Mach 1.81)** | M61K Precision 20mm | 4× MT-200 Meteorix | 2× IR-T Agile | *Conventional Only* | 14× LOG-70 Guided | 5× KD-50X |
| 6 | **TY-4 TEMPEST** | **2,495 km/h (Mach 2.35)** | BK-27X Revolver 27mm | 4× MT-200 Meteorix | 4× AS-132 IR | **1× STORM-N Standoff Nuclear (150kt)** | 38× CR-70 Dart | 5× EDASS |
| 7 | **S-47 BERKUT-V** | **1,717 km/h (Mach 1.65)** | GSh-30V 30mm | 4× R-73V Archer | *None* | *Conventional Only* | 10× S-13X 122mm | 4× APP-50X |
| 8 | **S-35X FLANKER-Z** | **2,400 km/h (Mach 2.25)** | GSh-30V 30mm | 6× R-77S Adder | 4× R-74X Archer-II | **1× KH-59N Heavy Nuclear (180kt)** | 40× S-8K 80mm | 7× UV-26X |
| 9 | **RF-3R RAFALIS** | **1,912 km/h (Mach 1.80)** | G-30M 791X 30mm | 4× MK-EM Radar | 4× MK-IR Seeker | **1× ASMP-R Ramjet Nuclear (300kt)** | 24× SN-68 68mm | 6× ECLAIR-X |
| 10 | **S-34X FULLBACK-B** | **1,900 km/h (Mach 1.80)** | GSh-30V 30mm | 2× R-77S Adder | *None* | **2× KH-102S Tactical Nuclear (250kt)** | 80× S-8K 80mm | 8× Heavy UV-26X |

---

## 2. Clean 360° Studio Image View & Zero-Mess Volumetric X-Ray Internals
- **360° Studio Image View**: Real photorealistic studio renders at `315° Front-Left 3/4`, `0° Head-On Front`, and `45° Front-Right 3/4` with interactive drag-to-rotate, zoom, and smooth optical crossfade (`assets/jets/*.png` + `assets/jets/360/*_front.png`).
- **Clean 360° X-Ray Internals**: Clean fuselage station hoops & perimeter outlines (no messy triangulated diagonal spiderwebs), well-separated solid internal modules (`AESA Radar`, `Cockpit / FBW`, `Cannon Drum`, `S-Duct Intakes`, `Turbofan Cores`, `Dorsal Fuel Bladders`, `Ventral Weapons / Nuclear Bay`), and toggleable 3D-tracked callout tags.
