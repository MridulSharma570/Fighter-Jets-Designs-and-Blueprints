extends Node
## Autoload Singleton: GameDatabase
## Legally-cleared minimal-change designations for all 10 Fighter Jets,
## Missiles, Rocket Pods, Cannons, and Tactical Nuclear Warheads.
## Nuclear warheads are assigned ONLY to the Top 3 jets at the top of the list.

var jets: Dictionary = {}
var jet_order: Array[String] = []
var missiles: Dictionary = {}
var rockets: Dictionary = {}
var cannons: Dictionary = {}

func _ready() -> void:
	_register_cannons()
	_register_missiles()
	_register_rockets()
	_register_jets()

func get_jet(id: String) -> AircraftData:
	return jets.get(id, null)

func get_missile(id: String) -> WeaponData.MissileSpec:
	return missiles.get(id, null)

func get_rocket(id: String) -> WeaponData.RocketSpec:
	return rockets.get(id, null)

func get_cannon(id: String) -> WeaponData.CannonSpec:
	return cannons.get(id, null)

func _register_cannons() -> void:
	_add_cannon("m61v_vulcanix", "M61V Vulcanix 20mm", 20.0, WeaponData.CannonAction.ROTARY_GATLING,
		6000, 6.4, 1050.0, 1650.0, 0.65, 0.25, 0.08, 0.011, 0.30, 480, Color(1.0, 0.88, 0.35), "vulcan_brrrt")
	_add_cannon("m61k_precision", "M61K Precision 20mm", 20.0, WeaponData.CannonAction.ROTARY_GATLING,
		6000, 6.8, 1080.0, 1750.0, 0.50, 0.28, 0.06, 0.010, 0.32, 480, Color(0.55, 0.95, 1.0), "vulcan_crisp")
	_add_cannon("gau_22x", "GAU-22X Equalizer 25mm", 25.0, WeaponData.CannonAction.ROTARY_GATLING,
		3300, 13.5, 1020.0, 1700.0, 0.55, 0.45, 0.10, 0.019, 0.28, 180, Color(1.0, 0.65, 0.25), "equalizer_25mm")
	_add_cannon("bk_27x", "BK-27X Revolver 27mm", 27.0, WeaponData.CannonAction.REVOLVER_CANNON,
		1700, 24.0, 1025.0, 1850.0, 0.48, 0.55, 0.02, 0.028, 0.30, 150, Color(1.0, 0.78, 0.40), "revolver_bk27")
	_add_cannon("gsh_30v", "GSh-30V Autocannon 30mm", 30.0, WeaponData.CannonAction.SINGLE_AUTOCANNON,
		1650, 29.0, 920.0, 1800.0, 0.62, 0.70, 0.01, 0.034, 0.26, 150, Color(1.0, 0.45, 0.20), "gsh30_boom")
	_add_cannon("g30m_791x", "G-30M 791X Revolver 30mm", 30.0, WeaponData.CannonAction.REVOLVER_CANNON,
		2500, 23.5, 1025.0, 1820.0, 0.52, 0.62, 0.02, 0.029, 0.28, 125, Color(0.95, 0.72, 0.30), "giat_snap")
	_add_cannon("cs_23v_pod", "CS-23V Stealth Pod 23mm (Opt.)", 23.0, WeaponData.CannonAction.STEALTH_CONCEALED_ROTARY,
		2400, 14.5, 970.0, 1680.0, 0.58, 0.38, 0.18, 0.018, 0.34, 240, Color(0.65, 1.0, 0.85), "stealth_23_buzz")

func _add_cannon(id: String, dname: String, cal: float, act: WeaponData.CannonAction,
		rpm: int, dmg: float, vel: float, rng: float, spread: float, pen: float,
		spin: float, heat: float, cool: float, mag: int, col: Color, snd: String) -> void:
	var c := WeaponData.CannonSpec.new()
	c.id = id; c.display_name = dname; c.caliber_mm = cal; c.action_type = act
	c.rpm = rpm; c.base_damage_per_round = dmg; c.muzzle_velocity_mps = vel
	c.effective_range_m = rng; c.spread_deg = spread; c.armor_penetration = pen
	c.spin_up_sec = spin; c.heat_per_shot = heat; c.cool_rate_per_sec = cool
	c.magazine_capacity = mag; c.tracer_color = col; c.sound_signature = snd
	cannons[id] = c

func _register_missiles() -> void:
	# Short-Range Infrared (Fox-2)
	_add_missile("am_9x", "AM-9X Block-II Viper", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 118.0, 920.0, 4200.0, 0.95, 42.0, 62.0, 18.0, 34.0, 0.25, 12.0, 4,
		0.0, 0.0, 0.0, false, Color(1.0, 0.78, 0.35), 0.7, 1.10)
	_add_missile("r_74x", "R-74X K-74 Archer-II", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 124.0, 900.0, 4200.0, 0.90, 48.0, 66.0, 20.0, 38.0, 0.22, 13.0, 4,
		0.0, 0.0, 0.0, false, Color(1.0, 0.55, 0.25), 0.85, 1.02)
	_add_missile("r_73v", "R-73V Vympel Archer", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 120.0, 880.0, 3900.0, 0.85, 46.0, 64.0, 19.0, 36.0, 0.20, 12.5, 4,
		0.0, 0.0, 0.0, false, Color(1.0, 0.50, 0.20), 0.85, 1.00)
	_add_missile("pl_10x", "PL-10X HOBS Infrared", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 122.0, 940.0, 4300.0, 0.92, 46.0, 64.0, 18.0, 35.0, 0.28, 13.0, 4,
		0.0, 0.0, 0.0, false, Color(0.95, 0.85, 0.45), 0.65, 1.08)
	_add_missile("ir_t", "IR-T Agile Thermal", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 115.0, 930.0, 4100.0, 0.85, 45.0, 68.0, 19.0, 34.0, 0.30, 11.5, 4,
		0.0, 0.0, 0.0, false, Color(0.7, 0.95, 1.0), 0.60, 1.15)
	_add_missile("as_132", "AS-132 High-Speed IR", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 126.0, 1120.0, 4800.0, 1.00, 40.0, 56.0, 18.0, 36.0, 0.26, 12.5, 4,
		0.0, 0.0, 0.0, false, Color(1.0, 0.90, 0.60), 0.65, 1.18)
	_add_missile("mk_ir", "MK-IR Dual-Seeker", WeaponData.MissileCategory.SHORT_RANGE_IR,
		WeaponData.GuidanceType.INFRARED, false, 120.0, 980.0, 4500.0, 0.95, 42.0, 60.0, 18.0, 35.0, 0.32, 12.0, 4,
		0.0, 0.0, 0.0, false, Color(0.55, 0.90, 1.0), 0.65, 1.12)

	# Medium-Range Active Radar (Fox-3)
	_add_missile("am_120d", "AM-120D Arrows BVR", WeaponData.MissileCategory.MEDIUM_RANGE_RADAR,
		WeaponData.GuidanceType.ACTIVE_RADAR, false, 155.0, 1250.0, 9400.0, 1.85, 30.0, 38.0, 22.0, 44.0, 0.52, 17.0, 3,
		0.0, 0.0, 0.0, false, Color(0.85, 0.92, 1.0), 0.8, 0.95)
	_add_missile("r_77v", "R-77V Adder-X", WeaponData.MissileCategory.MEDIUM_RANGE_RADAR,
		WeaponData.GuidanceType.ACTIVE_RADAR, false, 162.0, 1240.0, 9000.0, 1.80, 32.0, 40.0, 22.0, 46.0, 0.48, 17.0, 3,
		0.0, 0.0, 0.0, false, Color(1.0, 0.65, 0.30), 0.9, 0.92)
	_add_missile("r_77s", "R-77S RVV-SD Adder", WeaponData.MissileCategory.MEDIUM_RANGE_RADAR,
		WeaponData.GuidanceType.ACTIVE_RADAR, false, 154.0, 1200.0, 8600.0, 1.85, 30.0, 38.0, 22.0, 44.0, 0.45, 16.5, 4,
		0.0, 0.0, 0.0, false, Color(1.0, 0.60, 0.25), 0.9, 0.90)
	_add_missile("r_27v", "R-27V Alamo-X", WeaponData.MissileCategory.MEDIUM_RANGE_RADAR,
		WeaponData.GuidanceType.MANUAL_BEAM, false, 175.0, 1320.0, 8500.0, 1.65, 25.0, 32.0, 24.0, 50.0, 0.45, 16.0, 1,
		0.0, 0.0, 0.0, false, Color(1.0, 0.50, 0.20), 1.0, 0.86)
	_add_missile("mk_em", "MK-EM Active Radar", WeaponData.MissileCategory.MEDIUM_RANGE_RADAR,
		WeaponData.GuidanceType.ACTIVE_RADAR, false, 148.0, 1180.0, 8200.0, 1.60, 34.0, 44.0, 20.0, 42.0, 0.50, 15.5, 3,
		0.0, 0.0, 0.0, false, Color(0.65, 0.90, 1.0), 0.75, 0.98)

	# Long-Range BVR Ramjet / Hypersonic
	_add_missile("mt_200", "MT-200 Meteorix Ramjet", WeaponData.MissileCategory.LONG_RANGE_BVR,
		WeaponData.GuidanceType.RAMJET_DUAL_PULSE, false, 195.0, 1480.0, 14500.0, 2.50, 26.0, 42.0, 24.0, 52.0, 0.68, 22.0, 2,
		0.0, 0.0, 0.0, false, Color(0.55, 0.95, 1.0), 0.55, 0.88)
	_add_missile("pl_15x", "PL-15X Dragon-BVR", WeaponData.MissileCategory.LONG_RANGE_BVR,
		WeaponData.GuidanceType.RAMJET_DUAL_PULSE, false, 192.0, 1520.0, 15500.0, 2.65, 24.0, 36.0, 24.0, 50.0, 0.66, 22.0, 2,
		0.0, 0.0, 0.0, false, Color(0.75, 0.92, 1.0), 0.70, 0.85)
	_add_missile("r_37x", "R-37X Hypersonic BVR", WeaponData.MissileCategory.LONG_RANGE_BVR,
		WeaponData.GuidanceType.RAMJET_DUAL_PULSE, false, 235.0, 1850.0, 16500.0, 3.10, 20.0, 28.0, 28.0, 62.0, 0.72, 26.0, 1,
		0.0, 0.0, 0.0, false, Color(1.0, 0.45, 0.25), 0.95, 0.75)

	# Tactical Nuclear Warheads (Top-3 Roster Jets + Middle-to-Last Strike Jets #6, #8, #9, #10)
	_add_missile("kh_102x_nuke", "KH-102X Stealth Nuclear Cruise", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 1040.0, 860.0, 15000.0, 4.50, 25.0, 22.0, 60.0, 1400.0, 0.91, 50.0, 1,
		250.0, 2400.0, 15.0, true, Color(1.0, 0.68, 0.28), 0.5, 0.50)
	_add_missile("cj_20x_nuke", "CJ-20X Long-Range Nuclear", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 1010.0, 920.0, 15500.0, 4.40, 24.0, 22.0, 58.0, 1350.0, 0.92, 50.0, 1,
		200.0, 2350.0, 14.0, true, Color(0.75, 0.92, 1.0), 0.45, 0.52)
	_add_missile("b61n_nuke", "B-61N Guided Nuclear Bay Munition", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 980.0, 740.0, 12000.0, 4.20, 28.0, 24.0, 55.0, 1250.0, 0.93, 48.0, 1,
		80.0, 2250.0, 12.0, true, Color(1.0, 0.95, 0.65), 0.4, 0.55)
	_add_missile("storm_n_nuke", "STORM-N Standoff Nuclear", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 995.0, 960.0, 14000.0, 4.25, 25.0, 24.0, 56.0, 1300.0, 0.90, 48.0, 1,
		150.0, 2300.0, 13.0, true, Color(1.0, 0.76, 0.35), 0.45, 0.54)
	_add_missile("kh_59n_nuke", "KH-59N Heavy Nuclear Cruise", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 1020.0, 880.0, 14500.0, 4.45, 24.0, 22.0, 58.0, 1360.0, 0.91, 50.0, 1,
		180.0, 2350.0, 14.0, true, Color(1.0, 0.62, 0.25), 0.55, 0.50)
	_add_missile("asmp_r_nuke", "ASMP-R Ramjet Nuclear", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 1080.0, 1180.0, 15200.0, 4.10, 26.0, 26.0, 62.0, 1450.0, 0.93, 52.0, 1,
		300.0, 2450.0, 16.0, true, Color(0.55, 0.95, 1.0), 0.40, 0.58)
	_add_missile("kh_102s_nuke", "KH-102S Twin Tactical Nuclear", WeaponData.MissileCategory.NUCLEAR_TACTICAL,
		WeaponData.GuidanceType.NUCLEAR_INS_TERMINAL, true, 1050.0, 840.0, 15000.0, 4.60, 24.0, 20.0, 62.0, 1420.0, 0.90, 52.0, 2,
		250.0, 2450.0, 15.0, true, Color(1.0, 0.55, 0.22), 0.60, 0.48)

func _add_missile(id: String, dname: String, cat: WeaponData.MissileCategory,
		guid: WeaponData.GuidanceType, is_nuke: bool, dmg: float, spd: float,
		rng: float, lock_t: float, cone: float, turn: float, fuze: float,
		blast: float, flare_res: float, reload_t: float, max_air: int,
		yield_kt: float, emp_r: float, rad_t: float, destructible: bool,
		plume: Color, smoke: float, pitch: float) -> void:
	var m := WeaponData.MissileSpec.new()
	m.id = id; m.display_name = dname; m.category = cat; m.guidance = guid
	m.is_nuclear = is_nuke; m.base_damage = dmg; m.speed_mps = spd
	m.max_range_m = rng; m.lock_time_sec = lock_t; m.lock_cone_deg = cone
	m.turn_rate_deg_sec = turn; m.proximity_fuze_m = fuze; m.blast_radius_m = blast
	m.flare_resistance = flare_res; m.reload_time_sec = reload_t
	m.max_simultaneous_airborne = max_air; m.nuclear_yield_kt = yield_kt
	m.emp_radius_m = emp_r; m.radiation_duration_sec = rad_t
	m.destructible_in_flight = destructible; m.plume_color = plume
	m.smoke_thickness = smoke; m.launch_sound_pitch = pitch
	missiles[id] = m

func _register_rockets() -> void:
	_add_rocket("s8_kom", "B-8V Pod (S-8K 80mm HEAT)", 80, WeaponData.RocketGuidance.UNGUIDED_SALVO,
		34.0, 24.0, 710.0, 2900.0, 2.0, 14.0, 18.0, 0.15, Color(1.0, 0.55, 0.18), 1.05)
	_add_rocket("s13_heavy", "B-13V Pod (S-13X 122mm Bunker)", 122, WeaponData.RocketGuidance.UNGUIDED_SALVO,
		88.0, 42.0, 680.0, 3200.0, 1.5, 6.0, 22.0, 0.22, Color(1.0, 0.42, 0.12), 0.78)
	_add_rocket("s24_heavy", "AP-68 Rail (S-24X 240mm Heavy)", 240, WeaponData.RocketGuidance.UNGUIDED_SALVO,
		165.0, 68.0, 620.0, 3000.0, 1.2, 2.5, 25.0, 0.25, Color(1.0, 0.35, 0.10), 0.65)
	_add_rocket("log_70", "LOG-70 Guided Rocket Pod", 70, WeaponData.RocketGuidance.LASER_SEMI_GUIDED,
		44.0, 20.0, 790.0, 3800.0, 0.7, 10.0, 17.0, 0.14, Color(0.55, 0.95, 1.0), 1.22)
	_add_rocket("cr_70", "LAU-50V Pod (CR-70 Dart)", 70, WeaponData.RocketGuidance.UNGUIDED_SALVO,
		38.0, 20.0, 980.0, 3400.0, 1.1, 16.0, 16.0, 0.12, Color(1.0, 0.85, 0.45), 1.28)
	_add_rocket("sn_68", "TL-12 Pod (SN-68 68mm)", 68, WeaponData.RocketGuidance.UNGUIDED_SALVO,
		36.0, 19.0, 890.0, 3200.0, 1.2, 15.0, 16.0, 0.12, Color(0.95, 0.80, 0.45), 1.24)

func _add_rocket(id: String, dname: String, cal: int, guid: WeaponData.RocketGuidance,
		dmg: float, splash: float, spd: float, rng: float, disp: float,
		rps: float, reload_t: float, pen: float, plume: Color, pitch: float) -> void:
	var r := WeaponData.RocketSpec.new()
	r.id = id; r.display_name = dname; r.caliber_mm = cal; r.guidance = guid
	r.base_damage = dmg; r.splash_radius_m = splash; r.speed_mps = spd
	r.max_range_m = rng; r.dispersion_deg = disp; r.salvo_rate_rps = rps
	r.reload_time_sec = reload_t; r.stealth_penalty = pen
	r.plume_color = plume; r.sound_pitch = pitch
	rockets[id] = r

func _make_flare(id: String, dname: String, cap: int, cd: float, dur: float,
		pellets: int, ir: float, chaff: float, col: Color) -> WeaponData.FlareSpec:
	var f := WeaponData.FlareSpec.new()
	f.id = id; f.display_name = dname; f.capacity = cap; f.cooldown_sec = cd
	f.active_duration_sec = dur; f.pellets_per_burst = pellets
	f.ir_spoof_power = ir; f.radar_chaff_power = chaff; f.flare_color = col
	return f

func _make_trait(id: String, title: String, desc: String, turn := 0.0, rcs := 0.0,
		rad := 0.0, lock := 0.0, flare := 0.0, nuke := 0.0, armor := 0.0,
		cobra := false, supercruise := false) -> AircraftData.PassiveTrait:
	var t := AircraftData.PassiveTrait.new()
	t.id = id; t.title = title; t.description = desc
	t.turn_rate_bonus = turn; t.stealth_rcs_reduction = rcs
	t.radar_range_bonus = rad; t.lock_speed_bonus = lock
	t.flare_spoof_bonus = flare; t.nuclear_damage_bonus = nuke
	t.armor_damage_reduction = armor; t.enables_cobra_vectoring = cobra
	t.enables_supercruise = supercruise
	return t

func _make_ability(id: String, title: String, desc: String, dur: float,
		cd1: float, cd2: float, cd3: float, tag: String) -> AircraftData.SpecialAbility:
	var a := AircraftData.SpecialAbility.new()
	a.id = id; a.title = title; a.description = desc
	a.duration_sec = dur; a.cooldown_lv1 = cd1; a.cooldown_lv2 = cd2; a.cooldown_lv3 = cd3
	a.effect_tag = tag
	return a

func _register_jets() -> void:
	# 1. S-57 FELONIS (TOP OF LIST -> NUCLEAR ARMED, No External Rockets)
	var s57 := AircraftData.new()
	s57.id = "s_57_felonis"; s57.callsign_name = "S-57 FELONIS"; s57.designation = "5th-Gen Stealth Vectoring Dominance & Nuclear Striker"; s57.origin = "NORTH-EAST"
	s57.role = AircraftData.JetRole.SUPER_MANEUVER_BRAWLER; s57.blueprint_accent_color = Color(0.22, 0.88, 1.0)
	s57.livery_primary_color = Color(0.32, 0.42, 0.52); s57.livery_secondary_color = Color(0.18, 0.25, 0.34)
	s57.length_m = 20.1; s57.wingspan_m = 14.1; s57.height_m = 4.6; s57.empty_mass_kg = 18000.0; s57.combat_mass_kg = 25000.0
	s57.wing_area_m2 = 78.8; s57.aspect_ratio = 2.52; s57.dry_thrust_kn = 216.0; s57.afterburner_thrust_kn = 353.0; s57.max_g_limit = 9.0; s57.rcs_m2 = 0.05
	s57.base_hp = 178.0; s57.armor_rating = 0.14; s57.stealth_rating = 0.82; s57.detection_range_km = 3.5; s57.radar_range_km = 8.6; s57.radar_cone_deg = 38.0
	s57.cruise_speed_mps = 472.0; s57.max_speed_mps = 594.0; s57.pitch_rate_deg = 68.0; s57.roll_rate_deg = 178.0; s57.yaw_rate_deg = 40.0
	s57.has_thrust_vectoring = true; s57.wing_planform = "Chamfered LEVCON Stealth Trapezoid"
	s57.cannon_id = "gsh_30v"; s57.primary_missile_id = "r_77v"; s57.primary_missile_count = 4
	s57.secondary_missile_id = "r_74x"; s57.secondary_missile_count = 2
	s57.nuclear_missile_id = "kh_102x_nuke"; s57.nuclear_missile_count = 1
	s57.can_equip_rockets = false; s57.rocket_id = ""; s57.rocket_count = 0
	s57.flare_spec = _make_flare("uv50x", "UV-50X Spectral Decoys", 6, 4.0, 1.8, 10, 0.90, 0.62, Color(1.0, 0.90, 0.55))
	s57.passive_traits = [
		_make_trait("tvc_3d", "3D Nozzle Vectoring", "+30% high-AoA turn rate & Cobra post-stall snap.", 0.30, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, false),
		_make_trait("bay_stealth", "Internal Bay Stealth", "-45% enemy radar lock distance & carries 1x KH-102X Nuclear.", 0.0, 0.45, 0.0, 0.0, 0.0, 0.15)
	]
	s57.special_ability = _make_ability("vector_overdrive", "Cobra Vector Overdrive", "180-deg post-stall Cobra snap + 2x afterburner thrust burst.", 4.5, 45.0, 35.0, 25.0, "cobra_boost")
	s57.engine_sound_profile = "twin_serrated_al51"; s57.engine_base_pitch = 0.94; s57.blueprint_silhouette_type = "s57"
	_register_jet(s57)

	# 2. J-20X WYVERN (TOP OF LIST -> NUCLEAR ARMED, No Secondary Missiles, No Rockets)
	var j20 := AircraftData.new()
	j20.id = "j_20x_wyvern"; j20.callsign_name = "J-20X WYVERN"; j20.designation = "Long-Range Stealth BVR & Standoff Nuclear Interceptor"; j20.origin = "EASTERN"
	j20.role = AircraftData.JetRole.BVR_STEALTH_INTERCEPTOR; j20.blueprint_accent_color = Color(0.95, 0.72, 0.25)
	j20.livery_primary_color = Color(0.20, 0.23, 0.27); j20.livery_secondary_color = Color(0.13, 0.15, 0.18)
	j20.length_m = 21.2; j20.wingspan_m = 13.0; j20.height_m = 4.7; j20.empty_mass_kg = 17600.0; j20.combat_mass_kg = 25000.0
	j20.wing_area_m2 = 73.0; j20.aspect_ratio = 2.31; j20.dry_thrust_kn = 212.0; j20.afterburner_thrust_kn = 360.0; j20.max_g_limit = 9.0; j20.rcs_m2 = 0.01
	j20.base_hp = 168.0; j20.armor_rating = 0.10; j20.stealth_rating = 0.88; j20.detection_range_km = 3.1; j20.radar_range_km = 9.2; j20.radar_cone_deg = 42.0
	j20.cruise_speed_mps = 445.0; j20.max_speed_mps = 590.0; j20.pitch_rate_deg = 58.0; j20.roll_rate_deg = 155.0; j20.yaw_rate_deg = 32.0
	j20.has_thrust_vectoring = true; j20.has_canards = true; j20.wing_planform = "Notched Canard-Delta Stealth"
	j20.cannon_id = "cs_23v_pod"; j20.primary_missile_id = "pl_15x"; j20.primary_missile_count = 6
	j20.secondary_missile_id = ""; j20.secondary_missile_count = 0
	j20.nuclear_missile_id = "cj_20x_nuke"; j20.nuclear_missile_count = 1
	j20.can_equip_rockets = false; j20.rocket_id = ""; j20.rocket_count = 0
	j20.flare_spec = _make_flare("t935x", "T-935X Thermal-Chaff", 5, 4.5, 1.6, 8, 0.88, 0.65, Color(1.0, 0.85, 0.50))
	j20.passive_traits = [
		_make_trait("canard_stealth", "Canard-Vortex Stealth", "-50% enemy detection range; pure BVR + CJ-20X Nuclear bay.", 0.0, 0.50),
		_make_trait("eodas_360", "EO-360 Sensor Fusion", "+25% faster BVR lock acquisition & wider lock cone.", 0.0, 0.0, 0.15, 0.25)
	]
	j20.special_ability = _make_ability("flare_reload_cloak", "Flare Reload & Ghost Veil", "Instantly refills flares to 5/5 and suppresses radar/IR by 70%.", 5.0, 80.0, 60.0, 45.0, "flare_reload_cloak")
	j20.engine_sound_profile = "twin_ws15_howl"; j20.engine_base_pitch = 1.05; j20.blueprint_silhouette_type = "j20"
	_register_jet(j20)

	# 3. F-22V TALON (TOP OF LIST -> NUCLEAR ARMED, No External Rockets)
	var f22 := AircraftData.new()
	f22.id = "f_22v_talon"; f22.callsign_name = "F-22V TALON"; f22.designation = "Apex 5th-Gen Stealth Air Dominance & Nuclear Strike"; f22.origin = "ATLANTIC"
	f22.role = AircraftData.JetRole.STEALTH_AIR_DOMINANCE; f22.blueprint_accent_color = Color(0.30, 0.95, 0.72)
	f22.livery_primary_color = Color(0.36, 0.40, 0.45); f22.livery_secondary_color = Color(0.24, 0.27, 0.31)
	f22.length_m = 18.92; f22.wingspan_m = 13.56; f22.height_m = 5.08; f22.empty_mass_kg = 19700.0; f22.combat_mass_kg = 29410.0
	f22.wing_area_m2 = 78.04; f22.aspect_ratio = 2.36; f22.dry_thrust_kn = 232.0; f22.afterburner_thrust_kn = 312.0; f22.max_g_limit = 9.0; f22.rcs_m2 = 0.0001
	f22.base_hp = 175.0; f22.armor_rating = 0.14; f22.stealth_rating = 0.94; f22.detection_range_km = 2.7; f22.radar_range_km = 8.8; f22.radar_cone_deg = 36.0
	f22.cruise_speed_mps = 537.0; f22.max_speed_mps = 670.0; f22.pitch_rate_deg = 67.0; f22.roll_rate_deg = 175.0; f22.yaw_rate_deg = 36.0
	f22.has_thrust_vectoring = true; f22.wing_planform = "Clipped Diamond Trapezoid"
	f22.cannon_id = "m61v_vulcanix"; f22.primary_missile_id = "am_120d"; f22.primary_missile_count = 6
	f22.secondary_missile_id = "am_9x"; f22.secondary_missile_count = 2
	f22.nuclear_missile_id = "b61n_nuke"; f22.nuclear_missile_count = 1
	f22.can_equip_rockets = false; f22.rocket_id = ""; f22.rocket_count = 0
	f22.flare_spec = _make_flare("mju39x", "MJU-39X Spectral Flares", 6, 3.8, 1.7, 10, 0.92, 0.68, Color(1.0, 0.95, 0.70))
	f22.passive_traits = [
		_make_trait("apex_stealth", "True Aspect Stealth", "-55% radar cross-section; immune to BVR lock beyond 6.5 km.", 0.0, 0.55),
		_make_trait("supercruise_2d", "2D Vectoring & Supercruise", "Sustained Mach 1.8 cruise + internal B-61N Nuclear bay.", 0.20, 0.0, 0.0, 0.0, 0.0, 0.15, 0.0, true, true)
	]
	f22.special_ability = _make_ability("apex_overdrive", "Apex Supercruise", "+100% missile lock speed, +20% agility, and instant supercruise surge.", 6.0, 55.0, 42.0, 30.0, "apex_overdrive")
	f22.engine_sound_profile = "twin_f119_flat"; f22.engine_base_pitch = 1.00; f22.blueprint_silhouette_type = "f22"
	_register_jet(f22)

	# 4. F-35K THUNDER (NO Nuclear, NO Secondary Missiles, NO Rockets -> Pure Stealth EW)
	var f35 := AircraftData.new()
	f35.id = "f_35k_thunder"; f35.callsign_name = "F-35K THUNDER"; f35.designation = "Multi-Role Sensor-Fusion Stealth EW Striker"; f35.origin = "ATLANTIC"
	f35.role = AircraftData.JetRole.MULTI_ROLE_STEALTH_STRIKER; f35.blueprint_accent_color = Color(0.42, 0.78, 1.0)
	f35.livery_primary_color = Color(0.24, 0.27, 0.31); f35.livery_secondary_color = Color(0.38, 0.42, 0.48)
	f35.length_m = 15.67; f35.wingspan_m = 10.7; f35.height_m = 4.38; f35.empty_mass_kg = 13290.0; f35.combat_mass_kg = 22470.0
	f35.wing_area_m2 = 42.7; f35.aspect_ratio = 2.68; f35.dry_thrust_kn = 125.0; f35.afterburner_thrust_kn = 191.0; f35.max_g_limit = 9.0; f35.rcs_m2 = 0.0015
	f35.base_hp = 180.0; f35.armor_rating = 0.16; f35.stealth_rating = 0.90; f35.detection_range_km = 2.9; f35.radar_range_km = 8.6; f35.radar_cone_deg = 50.0
	f35.cruise_speed_mps = 354.0; f35.max_speed_mps = 536.0; f35.pitch_rate_deg = 56.0; f35.roll_rate_deg = 160.0; f35.yaw_rate_deg = 32.0
	f35.wing_planform = "Single-Engine Stealth Trapezoid"
	f35.cannon_id = "gau_22x"; f35.primary_missile_id = "am_120d"; f35.primary_missile_count = 4
	f35.secondary_missile_id = ""; f35.secondary_missile_count = 0
	f35.nuclear_missile_id = ""; f35.nuclear_missile_count = 0
	f35.can_equip_rockets = false; f35.rocket_id = ""; f35.rocket_count = 0
	f35.flare_spec = _make_flare("mju61x", "MJU-61X Smart Flares", 4, 4.5, 1.8, 9, 0.90, 0.72, Color(1.0, 0.92, 0.60))
	f35.passive_traits = [
		_make_trait("das_360", "DAS 360° Aperture", "Tracks and retains missile locks even behind aircraft (+30% lock).", 0.0, 0.45, 0.15, 0.30),
		_make_trait("ew_array", "AESA Cyber Dominance", "+20% EW pulse radius & flare decoy effectiveness.", 0.0, 0.0, 0.15, 0.0, 0.20)
	]
	f35.special_ability = _make_ability("ew_cyber_jammer", "AESA Cyber Jammer", "Scrambles all enemy HUDs and breaks locks within 4.5 km radius.", 5.0, 60.0, 45.0, 32.0, "ew_jammer")
	f35.engine_count = 1; f35.engine_sound_profile = "single_f135_thunder"; f35.engine_base_pitch = 0.76; f35.blueprint_silhouette_type = "f35"
	_register_jet(f35)

	# 5. KF-21M BORAMA (No Nuke, Has Rockets)
	var kf21 := AircraftData.new()
	kf21.id = "kf_21m_borama"; kf21.callsign_name = "KF-21M BORAMA"; kf21.designation = "4.5++ Gen Semi-Stealth Twin Multi-Role"; kf21.origin = "PACIFIC"
	kf21.role = AircraftData.JetRole.MULTI_ROLE_STEALTH_STRIKER; kf21.blueprint_accent_color = Color(0.40, 0.92, 0.98)
	kf21.livery_primary_color = Color(0.35, 0.40, 0.46); kf21.livery_secondary_color = Color(0.22, 0.26, 0.32)
	kf21.length_m = 16.9; kf21.wingspan_m = 11.2; kf21.height_m = 4.7; kf21.empty_mass_kg = 11800.0; kf21.combat_mass_kg = 20500.0
	kf21.wing_area_m2 = 46.5; kf21.aspect_ratio = 2.70; kf21.dry_thrust_kn = 115.6; kf21.afterburner_thrust_kn = 195.8; kf21.max_g_limit = 9.0; kf21.rcs_m2 = 0.08
	kf21.base_hp = 155.0; kf21.armor_rating = 0.10; kf21.stealth_rating = 0.65; kf21.detection_range_km = 4.2; kf21.radar_range_km = 8.0; kf21.radar_cone_deg = 36.0
	kf21.cruise_speed_mps = 355.0; kf21.max_speed_mps = 611.0; kf21.pitch_rate_deg = 62.0; kf21.roll_rate_deg = 172.0; kf21.yaw_rate_deg = 34.0
	kf21.wing_planform = "Canted Twin-Tail Trapezoid"
	kf21.cannon_id = "m61k_precision"; kf21.primary_missile_id = "mt_200"; kf21.primary_missile_count = 4
	kf21.secondary_missile_id = "ir_t"; kf21.secondary_missile_count = 2
	kf21.nuclear_missile_id = ""; kf21.nuclear_missile_count = 0
	kf21.can_equip_rockets = true; kf21.rocket_id = "log_70"; kf21.rocket_count = 14
	kf21.flare_spec = _make_flare("kd50x", "KD-50X Countermeasure Salvo", 5, 4.0, 1.5, 8, 0.86, 0.60, Color(0.85, 0.96, 1.0))
	kf21.passive_traits = [
		_make_trait("recessed_rcs", "Semi-Recessed Stealth", "-25% RCS while retaining wing pylons.", 0.0, 0.25),
		_make_trait("quick_avionics", "Quick-Cycle Avionics", "+25% faster missile lock speed & weapon reload cadence.", 0.0, 0.0, 0.0, 0.25)
	]
	kf21.special_ability = _make_ability("rapid_salvo_link", "Dual-Link Salvo", "Simultaneous dual-target BVR lock & halves lock-on timer.", 6.0, 50.0, 38.0, 28.0, "rapid_salvo")
	kf21.engine_sound_profile = "twin_f414_crisp"; kf21.engine_base_pitch = 1.12; kf21.blueprint_silhouette_type = "kf21"
	_register_jet(kf21)

	# 6. TY-4 TEMPEST (Middle-List -> 1x STORM-N Nuclear, Has Rockets)
	var ty4 := AircraftData.new()
	ty4.id = "ty_4_tempest"; ty4.callsign_name = "TY-4 TEMPEST"; ty4.designation = "Canard-Delta High-Altitude Energy & Nuclear Interceptor"; ty4.origin = "EURO"
	ty4.role = AircraftData.JetRole.ENERGY_DELTA_DOGFIGHTER; ty4.blueprint_accent_color = Color(0.95, 0.52, 0.22)
	ty4.livery_primary_color = Color(0.42, 0.46, 0.50); ty4.livery_secondary_color = Color(0.28, 0.31, 0.35)
	ty4.length_m = 15.96; ty4.wingspan_m = 10.95; ty4.height_m = 5.28; ty4.empty_mass_kg = 11000.0; ty4.combat_mass_kg = 16000.0
	ty4.wing_area_m2 = 51.2; ty4.aspect_ratio = 2.34; ty4.dry_thrust_kn = 120.0; ty4.afterburner_thrust_kn = 180.0; ty4.max_g_limit = 9.0; ty4.rcs_m2 = 0.25
	ty4.base_hp = 160.0; ty4.armor_rating = 0.12; ty4.stealth_rating = 0.45; ty4.detection_range_km = 4.9; ty4.radar_range_km = 8.4; ty4.radar_cone_deg = 34.0
	ty4.cruise_speed_mps = 443.0; ty4.max_speed_mps = 693.0; ty4.pitch_rate_deg = 64.0; ty4.roll_rate_deg = 176.0; ty4.yaw_rate_deg = 34.0
	ty4.has_canards = true; ty4.wing_planform = "Unstable Canard-Delta"
	ty4.cannon_id = "bk_27x"; ty4.primary_missile_id = "mt_200"; ty4.primary_missile_count = 4
	ty4.secondary_missile_id = "as_132"; ty4.secondary_missile_count = 4
	ty4.nuclear_missile_id = "storm_n_nuke"; ty4.nuclear_missile_count = 1
	ty4.can_equip_rockets = true; ty4.rocket_id = "cr_70"; ty4.rocket_count = 38
	ty4.flare_spec = _make_flare("edass", "EDASS Praetorian Flares", 5, 4.0, 1.6, 9, 0.88, 0.65, Color(1.0, 0.88, 0.45))
	ty4.passive_traits = [
		_make_trait("delta_energy", "Unstable Canard-Delta", "+22% sustained turn rate at supersonic speeds & supercruise.", 0.22, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, true),
		_make_trait("irst_passive", "Passive IRST Track", "+40% passive IR lock range without triggering enemy RWR.", 0.0, 0.15, 0.20, 0.15)
	]
	ty4.special_ability = _make_ability("reheat_surge", "Combat Reheat Surge", "Instant fuel refill + 35% thrust acceleration overdrive.", 5.0, 50.0, 40.0, 30.0, "reheat_surge")
	ty4.engine_sound_profile = "twin_ej200_crack"; ty4.engine_base_pitch = 1.08; ty4.blueprint_silhouette_type = "typhoon"
	_register_jet(ty4)

	# 7. S-47 BERKUT-V (No Secondary Missiles, No Nuke, Has Rockets)
	var s47 := AircraftData.new()
	s47.id = "s_47_berkut_v"; s47.callsign_name = "S-47 BERKUT-V"; s47.designation = "Forward-Swept Wing Experimental Dogfighter"; s47.origin = "NORTH-EAST"
	s47.role = AircraftData.JetRole.SUPER_MANEUVER_BRAWLER; s47.blueprint_accent_color = Color(1.0, 0.35, 0.42)
	s47.livery_primary_color = Color(0.08, 0.09, 0.11); s47.livery_secondary_color = Color(0.85, 0.88, 0.92)
	s47.length_m = 22.6; s47.wingspan_m = 16.7; s47.height_m = 6.3; s47.empty_mass_kg = 16375.0; s47.combat_mass_kg = 25000.0
	s47.wing_area_m2 = 61.87; s47.aspect_ratio = 4.50; s47.dry_thrust_kn = 186.0; s47.afterburner_thrust_kn = 304.0; s47.max_g_limit = 9.0; s47.rcs_m2 = 0.20
	s47.base_hp = 152.0; s47.armor_rating = 0.08; s47.stealth_rating = 0.55; s47.detection_range_km = 4.5; s47.radar_range_km = 7.4; s47.radar_cone_deg = 40.0
	s47.cruise_speed_mps = 320.0; s47.max_speed_mps = 477.0; s47.pitch_rate_deg = 76.0; s47.roll_rate_deg = 198.0; s47.yaw_rate_deg = 45.0
	s47.stall_speed_mps = 55.0; s47.has_thrust_vectoring = true; s47.has_canards = true; s47.wing_planform = "Forward-Swept Composite Wing"
	s47.cannon_id = "gsh_30v"; s47.primary_missile_id = "r_73v"; s47.primary_missile_count = 4
	s47.secondary_missile_id = ""; s47.secondary_missile_count = 0
	s47.nuclear_missile_id = ""; s47.nuclear_missile_count = 0
	s47.can_equip_rockets = true; s47.rocket_id = "s13_heavy"; s47.rocket_count = 10
	s47.flare_spec = _make_flare("app50x", "APP-50X Experimental Flares", 4, 4.2, 1.7, 8, 0.87, 0.58, Color(1.0, 0.72, 0.35))
	s47.passive_traits = [
		_make_trait("fsw_lift", "Forward-Swept Wing Lift", "Anti-stall down to 55 m/s + 35% snap pitch/roll authority.", 0.35, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, false),
		_make_trait("composite_agility", "Knife-Fight Predator", "Ultra-tight short-range turn radius & missile dodge window.", 0.15, 0.15)
	]
	s47.special_ability = _make_ability("kulbit_spin", "Kulbit Spin Break", "360-deg post-stall Kulbit flip that snaps onto tails & breaks incoming locks.", 4.0, 48.0, 36.0, 26.0, "kulbit_break")
	s47.engine_sound_profile = "twin_d30f6_growl"; s47.engine_base_pitch = 0.88; s47.blueprint_silhouette_type = "su47"
	_register_jet(s47)

	# 8. S-35X FLANKER-Z (Nuclear Cruise + Secondary + Rockets)
	var s35 := AircraftData.new()
	s35.id = "s_35x_flanker_z"; s35.callsign_name = "S-35X FLANKER-Z"; s35.designation = "4++ Gen Heavy Arsenal & Nuclear Strike Brawler"; s35.origin = "NORTH-EAST"
	s35.role = AircraftData.JetRole.SUPER_MANEUVER_BRAWLER; s35.blueprint_accent_color = Color(0.32, 0.72, 1.0)
	s35.livery_primary_color = Color(0.28, 0.35, 0.44); s35.livery_secondary_color = Color(0.45, 0.62, 0.78)
	s35.length_m = 21.9; s35.wingspan_m = 15.3; s35.height_m = 5.9; s35.empty_mass_kg = 18400.0; s35.combat_mass_kg = 25300.0
	s35.wing_area_m2 = 62.0; s35.aspect_ratio = 3.77; s35.dry_thrust_kn = 172.6; s35.afterburner_thrust_kn = 284.4; s35.max_g_limit = 9.0; s35.rcs_m2 = 1.5
	s35.base_hp = 185.0; s35.armor_rating = 0.16; s35.stealth_rating = 0.35; s35.detection_range_km = 5.4; s35.radar_range_km = 9.5; s35.radar_cone_deg = 44.0
	s35.cruise_speed_mps = 365.0; s35.max_speed_mps = 667.0; s35.pitch_rate_deg = 70.0; s35.roll_rate_deg = 178.0; s35.yaw_rate_deg = 42.0
	s35.has_thrust_vectoring = true; s35.wing_planform = "Twin-Tail Flanker Blended Wing"
	s35.cannon_id = "gsh_30v"; s35.primary_missile_id = "r_77s"; s35.primary_missile_count = 6
	s35.secondary_missile_id = "r_74x"; s35.secondary_missile_count = 4
	s35.nuclear_missile_id = "kh_59n_nuke"; s35.nuclear_missile_count = 1
	s35.can_equip_rockets = true; s35.rocket_id = "s8_kom"; s35.rocket_count = 40
	s35.flare_spec = _make_flare("uv26x", "UV-26X High-Cap Flares", 7, 3.5, 1.8, 12, 0.90, 0.64, Color(1.0, 0.85, 0.40))
	s35.passive_traits = [
		_make_trait("arsenal_12", "12-Hardpoint Arsenal", "Massive 10-missile + 40-rocket capacity.", 0.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, false),
		_make_trait("irbis_burn", "High-Power Burn-Through Radar", "9.5 km radar reach; cuts through enemy stealth by 25%.", 0.0, 0.0, 0.25, 0.15)
	]
	s35.special_ability = _make_ability("barrage_overclock", "4-Missile Ripple", "Simultaneous 4-missile ripple fire with +25% missile turn G-limit.", 6.0, 55.0, 44.0, 33.0, "missile_barrage")
	s35.engine_sound_profile = "twin_al41f1s_roar"; s35.engine_base_pitch = 0.90; s35.blueprint_silhouette_type = "su35"
	_register_jet(s35)

	# 9. RF-3R RAFALIS (1x ASMP-R Nuclear Ramjet, Has Secondary + Rockets)
	var rf3 := AircraftData.new()
	rf3.id = "rf_3r_rafalis"; rf3.callsign_name = "RF-3R RAFALIS"; rf3.designation = "Omnirole Delta-Canard EW & Nuclear Deterrence Striker"; rf3.origin = "EURO"
	rf3.role = AircraftData.JetRole.ENERGY_DELTA_DOGFIGHTER; rf3.blueprint_accent_color = Color(0.45, 0.82, 1.0)
	rf3.livery_primary_color = Color(0.36, 0.41, 0.47); rf3.livery_secondary_color = Color(0.25, 0.29, 0.34)
	rf3.length_m = 15.27; rf3.wingspan_m = 10.90; rf3.height_m = 5.34; rf3.empty_mass_kg = 10300.0; rf3.combat_mass_kg = 15000.0
	rf3.wing_area_m2 = 45.7; rf3.aspect_ratio = 2.60; rf3.dry_thrust_kn = 100.0; rf3.afterburner_thrust_kn = 150.0; rf3.max_g_limit = 9.0; rf3.rcs_m2 = 0.15
	rf3.base_hp = 162.0; rf3.armor_rating = 0.12; rf3.stealth_rating = 0.62; rf3.detection_range_km = 4.1; rf3.radar_range_km = 8.2; rf3.radar_cone_deg = 38.0
	rf3.cruise_speed_mps = 385.0; rf3.max_speed_mps = 531.0; rf3.pitch_rate_deg = 66.0; rf3.roll_rate_deg = 182.0; rf3.yaw_rate_deg = 35.0
	rf3.has_canards = true; rf3.wing_planform = "Close-Coupled Canard Delta"
	rf3.cannon_id = "g30m_791x"; rf3.primary_missile_id = "mk_em"; rf3.primary_missile_count = 4
	rf3.secondary_missile_id = "mk_ir"; rf3.secondary_missile_count = 4
	rf3.nuclear_missile_id = "asmp_r_nuke"; rf3.nuclear_missile_count = 1
	rf3.can_equip_rockets = true; rf3.rocket_id = "sn_68"; rf3.rocket_count = 24
	rf3.flare_spec = _make_flare("eclair_x", "ECLAIR-X Decoys", 6, 3.8, 1.6, 10, 0.93, 0.75, Color(0.95, 0.90, 0.65))
	rf3.passive_traits = [
		_make_trait("ew_suite", "Active EW Suite", "+20% flare decoy spoof chance & active stealth cancellation.", 0.12, 0.28, 0.0, 0.10, 0.20),
		_make_trait("omni_delta", "Omnirole Snap Agility", "+15% sustained roll & instantaneous turn snap.", 0.15)
	]
	rf3.special_ability = _make_ability("ew_ghost_pulse", "EW Ghost Pulse", "Active radar cancellation breaks enemy locks + 25% turn rate burst.", 4.5, 52.0, 40.0, 30.0, "spectra_ghost")
	rf3.engine_sound_profile = "twin_m88_snappy"; rf3.engine_base_pitch = 1.15; rf3.blueprint_silhouette_type = "rafale"
	_register_jet(rf3)

	# 10. S-34X FULLBACK-B (Twin Tactical Nuclear Strike + No Secondary Missiles + Massive 80x Rockets)
	var s34 := AircraftData.new()
	s34.id = "s_34x_fullback_b"; s34.callsign_name = "S-34X FULLBACK-B"; s34.designation = "Armored Twin-Seat Nuclear Strike & Heavy Rocket Gunship"; s34.origin = "NORTH-EAST"
	s34.role = AircraftData.JetRole.HEAVY_ARMORED_STRIKE; s34.blueprint_accent_color = Color(0.98, 0.48, 0.25)
	s34.livery_primary_color = Color(0.24, 0.24, 0.28); s34.livery_secondary_color = Color(0.42, 0.68, 0.85)
	s34.length_m = 23.34; s34.wingspan_m = 14.70; s34.height_m = 6.09; s34.empty_mass_kg = 22500.0; s34.combat_mass_kg = 39000.0
	s34.wing_area_m2 = 62.04; s34.aspect_ratio = 3.48; s34.dry_thrust_kn = 152.0; s34.afterburner_thrust_kn = 266.0; s34.max_g_limit = 7.0; s34.rcs_m2 = 2.5
	s34.base_hp = 265.0; s34.armor_rating = 0.28; s34.stealth_rating = 0.25; s34.detection_range_km = 5.8; s34.radar_range_km = 8.0; s34.radar_cone_deg = 36.0
	s34.cruise_speed_mps = 325.0; s34.max_speed_mps = 528.0; s34.pitch_rate_deg = 50.0; s34.roll_rate_deg = 135.0; s34.yaw_rate_deg = 28.0
	s34.has_canards = true; s34.wing_planform = "Platypus Canard Heavy Flanker"
	s34.cannon_id = "gsh_30v"; s34.primary_missile_id = "r_77s"; s34.primary_missile_count = 2
	s34.secondary_missile_id = ""; s34.secondary_missile_count = 0
	s34.nuclear_missile_id = "kh_102s_nuke"; s34.nuclear_missile_count = 2
	s34.can_equip_rockets = true; s34.rocket_id = "s8_kom"; s34.rocket_count = 80
	s34.flare_spec = _make_flare("heavy_uv26x", "Heavy Salvo UV-26X/APP", 8, 3.2, 2.0, 14, 0.92, 0.70, Color(1.0, 0.80, 0.35))
	s34.passive_traits = [
		_make_trait("titanium_tub", "Titanium Armored Tub", "+55% base HP & 25% cannon/shrapnel damage reduction.", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25),
		_make_trait("heavy_ordnance", "Heavy Rocket Gunship", "Carries 80x S-8K Rockets + 8x High-Cap Flare Salvos.", 0.0, 0.0, 0.0, 0.0, 0.15)
	]
	s34.special_ability = _make_ability("armor_brace_salvo", "Titanium Armor Brace", "40% damage shield + 25% larger rocket blast radius.", 6.0, 60.0, 48.0, 36.0, "armor_brace")
	s34.engine_sound_profile = "twin_al31fm1_bomber"; s34.engine_base_pitch = 0.80; s34.blueprint_silhouette_type = "su34"
	_register_jet(s34)

func _register_jet(jet: AircraftData) -> void:
	jets[jet.id] = jet
	jet_order.append(jet.id)
