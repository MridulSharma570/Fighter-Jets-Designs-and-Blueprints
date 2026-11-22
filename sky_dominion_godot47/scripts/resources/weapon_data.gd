class_name WeaponData
extends Resource
## Base weapon resource definitions and Level 1-20 scaling for Missiles,
## Nuclear Warheads, Rocket Pods, Cannons, and Flare Countermeasures.

enum MissileCategory {
	SHORT_RANGE_IR,      ## Fox-2 Heat-Seeking (high off-boresight, fast lock)
	MEDIUM_RANGE_RADAR,  ## Fox-3 / SARH Balanced Active Radar
	LONG_RANGE_BVR,      ## Fox-3+ Ramjet / Dual-Pulse Hypersonic
	NUCLEAR_TACTICAL,    ## Tactical Nuclear Glide / Cruise Missile
}

enum GuidanceType {
	INFRARED,
	ACTIVE_RADAR,
	MANUAL_BEAM,
	RAMJET_DUAL_PULSE,
	NUCLEAR_INS_TERMINAL,
}

enum RocketGuidance {
	UNGUIDED_SALVO,
	LASER_SEMI_GUIDED,
}

enum CannonAction {
	ROTARY_GATLING,
	REVOLVER_CANNON,
	SINGLE_AUTOCANNON,
	STEALTH_CONCEALED_ROTARY,
}


class MissileSpec extends Resource:
	@export var id: String
	@export var display_name: String
	@export var category: MissileCategory = MissileCategory.SHORT_RANGE_IR
	@export var guidance: GuidanceType = GuidanceType.INFRARED
	@export var is_nuclear: bool = false

	@export_group("Ballistics & Guidance")
	@export var base_damage: float = 120.0
	@export var speed_mps: float = 950.0
	@export var max_range_m: float = 4200.0
	@export var lock_time_sec: float = 1.1
	@export var lock_cone_deg: float = 38.0
	@export var turn_rate_deg_sec: float = 55.0
	@export var proximity_fuze_m: float = 18.0
	@export var blast_radius_m: float = 35.0
	@export var flare_resistance: float = 0.15  ## 0.0 (easily decoyed) -> 0.95 (ECCM resistant)
	@export var reload_time_sec: float = 14.0
	@export var max_simultaneous_airborne: int = 4

	@export_group("Nuclear Parameters")
	@export var nuclear_yield_kt: float = 0.0
	@export var emp_radius_m: float = 0.0
	@export var radiation_duration_sec: float = 0.0
	@export var destructible_in_flight: bool = false
	@export var warhead_hp: float = 40.0

	@export_group("Audio & VFX Profile")
	@export var plume_color: Color = Color(1.0, 0.72, 0.25, 1.0)
	@export var smoke_thickness: float = 0.75
	@export var launch_sound_pitch: float = 1.0
	@export var trail_width: float = 0.35

	func get_scaled_damage(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return base_damage * (1.0 + (lv - 1) * 0.07)

	func get_scaled_lock_time(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return lock_time_sec / (1.0 + (lv - 1) * 0.02)

	func get_scaled_turn_rate(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return turn_rate_deg_sec * (1.0 + (lv - 1) * 0.015)

	func get_scaled_flare_resistance(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return clampf(flare_resistance + (lv - 1) * 0.01, 0.0, 0.96)


class RocketSpec extends Resource:
	@export var id: String
	@export var display_name: String
	@export var caliber_mm: int = 80
	@export var guidance: RocketGuidance = RocketGuidance.UNGUIDED_SALVO
	@export var base_damage: float = 36.0
	@export var splash_radius_m: float = 22.0
	@export var speed_mps: float = 720.0
	@export var max_range_m: float = 3000.0
	@export var dispersion_deg: float = 1.8
	@export var salvo_rate_rps: float = 12.0
	@export var reload_time_sec: float = 18.0
	@export var stealth_penalty: float = 0.15  ## External pod drag/RCS penalty
	@export var plume_color: Color = Color(1.0, 0.5, 0.15, 1.0)
	@export var sound_pitch: float = 1.15

	func get_scaled_damage(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return base_damage * (1.0 + (lv - 1) * 0.075)

	func get_scaled_splash(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return splash_radius_m * (1.0 + (lv - 1) * 0.015)

	func get_scaled_dispersion(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return dispersion_deg * maxf(0.55, 1.0 - (lv - 1) * 0.02)


class CannonSpec extends Resource:
	@export var id: String
	@export var display_name: String
	@export var caliber_mm: float = 20.0
	@export var action_type: CannonAction = CannonAction.ROTARY_GATLING
	@export var rpm: int = 6000
	@export var base_damage_per_round: float = 6.5
	@export var muzzle_velocity_mps: float = 1050.0
	@export var effective_range_m: float = 1600.0
	@export var spread_deg: float = 0.65
	@export var armor_penetration: float = 0.25
	@export var spin_up_sec: float = 0.08
	@export var heat_per_shot: float = 0.012
	@export var cool_rate_per_sec: float = 0.28
	@export var magazine_capacity: int = 480
	@export var tracer_color: Color = Color(1.0, 0.85, 0.35, 1.0)
	@export var sound_signature: String = "vulcan_brrrt"

	func get_scaled_damage(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return base_damage_per_round * (1.0 + (lv - 1) * 0.065)

	func get_scaled_dps(level: int) -> float:
		return get_scaled_damage(level) * (float(rpm) / 60.0)

	func get_scaled_overheat_factor(level: int) -> float:
		var lv := clampi(level, 1, 20)
		return 1.0 + (lv - 1) * 0.025


class FlareSpec extends Resource:
	@export var id: String
	@export var display_name: String
	@export var capacity: int = 5
	@export var cooldown_sec: float = 4.0
	@export var active_duration_sec: float = 1.7
	@export var pellets_per_burst: int = 8
	@export var ir_spoof_power: float = 0.88
	@export var radar_chaff_power: float = 0.55
	@export var reload_time_sec: float = 28.0
	@export var flare_color: Color = Color(1.0, 0.92, 0.65, 1.0)
