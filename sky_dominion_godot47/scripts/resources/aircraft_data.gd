class_name AircraftData
extends Resource
## Aerodynamic Fighter Jet specification, Airframe Traits & Overdrive resource.
## Includes aerodynamic physics parameters (mass, wing area, aspect ratio, thrust)
## and authentic asymmetrical armament (not all jets carry nukes, secondary missiles, or rockets).

enum JetRole {
	STEALTH_AIR_DOMINANCE,
	BVR_STEALTH_INTERCEPTOR,
	MULTI_ROLE_STEALTH_STRIKER,
	ENERGY_DELTA_DOGFIGHTER,
	SUPER_MANEUVER_BRAWLER,
	HEAVY_ARMORED_STRIKE,
}

class PassiveTrait extends Resource:
	@export var id: String
	@export var title: String
	@export var description: String
	@export var turn_rate_bonus: float = 0.0
	@export var stealth_rcs_reduction: float = 0.0
	@export var radar_range_bonus: float = 0.0
	@export var lock_speed_bonus: float = 0.0
	@export var flare_spoof_bonus: float = 0.0
	@export var nuclear_damage_bonus: float = 0.0
	@export var armor_damage_reduction: float = 0.0
	@export var enables_cobra_vectoring: bool = false
	@export var enables_supercruise: bool = false

class SpecialAbility extends Resource:
	@export var id: String
	@export var title: String
	@export var description: String
	@export var duration_sec: float = 5.0
	@export var cooldown_lv1: float = 60.0
	@export var cooldown_lv2: float = 48.0
	@export var cooldown_lv3: float = 36.0
	@export var effect_tag: String = ""

	func get_cooldown(ability_level: int) -> float:
		match clampi(ability_level, 1, 3):
			1: return cooldown_lv1
			2: return cooldown_lv2
			_: return cooldown_lv3

@export var id: String
@export var callsign_name: String
@export var designation: String
@export var origin: String
@export var role: JetRole = JetRole.STEALTH_AIR_DOMINANCE
@export var blueprint_accent_color: Color = Color(0.18, 0.85, 1.0)
@export var livery_primary_color: Color = Color(0.28, 0.34, 0.42)
@export var livery_secondary_color: Color = Color(0.18, 0.22, 0.28)

@export_group("Real-World Dimensions & Aerodynamic Physics")
@export var length_m: float = 19.8
@export var wingspan_m: float = 14.0
@export var height_m: float = 4.7
@export var empty_mass_kg: float = 18500.0
@export var combat_mass_kg: float = 25000.0
@export var wing_area_m2: float = 78.8
@export var aspect_ratio: float = 2.5
@export var oswald_efficiency: float = 0.80
@export var zero_lift_drag_cd0: float = 0.018
@export var dry_thrust_kn: float = 216.0
@export var afterburner_thrust_kn: float = 350.0
@export var max_g_limit: float = 9.0
@export var service_ceiling_m: float = 20000.0
@export var rcs_m2: float = 0.001

@export_group("Airframe & Survivability")
@export var base_hp: float = 165.0
@export var armor_rating: float = 0.12
@export var stealth_rating: float = 0.75
@export var detection_range_km: float = 4.0
@export var radar_range_km: float = 8.0
@export var radar_cone_deg: float = 36.0

@export_group("Flight & Maneuverability")
@export var cruise_speed_mps: float = 350.0
@export var max_speed_mps: float = 670.0
@export var afterburner_accel: float = 100.0
@export var pitch_rate_deg: float = 64.0
@export var roll_rate_deg: float = 175.0
@export var yaw_rate_deg: float = 36.0
@export var stall_speed_mps: float = 72.0
@export var fuel_regen_sec: float = 15.0
@export var has_thrust_vectoring: bool = false
@export var has_canards: bool = false
@export var wing_planform: String = "Stealth Trapezoid"

@export_group("Authentic Asymmetrical Armament")
@export var cannon_id: String = ""
@export var primary_missile_id: String = ""
@export var primary_missile_count: int = 4
@export var secondary_missile_id: String = ""     ## Empty if jet carries no secondary missile class
@export var secondary_missile_count: int = 0
@export var nuclear_missile_id: String = ""       ## Only nuclear-capable platforms (F-35, Rafale, Su-34)
@export var nuclear_missile_count: int = 0
@export var can_equip_rockets: bool = false       ## False for pure 5th-gen internal stealth jets
@export var rocket_id: String = ""
@export var rocket_count: int = 0
@export var flare_spec: WeaponData.FlareSpec

@export_group("Airframe Traits & Overdrive Ability")
@export var passive_traits: Array[PassiveTrait] = []
@export var special_ability: SpecialAbility

@export_group("Audio & VFX Identity")
@export var engine_count: int = 2
@export var engine_sound_profile: String = "twin_heavy_turbine"
@export var engine_base_pitch: float = 1.0
@export var afterburner_color_core: Color = Color(0.45, 0.85, 1.0, 1.0)
@export var afterburner_color_outer: Color = Color(1.0, 0.52, 0.15, 1.0)
@export var blueprint_silhouette_type: String = "su57"

func get_scaled_hp(jet_level: int) -> float:
	var lv := clampi(jet_level, 1, 20)
	return base_hp * (1.0 + (lv - 1) * 0.065)

func get_scaled_max_speed(jet_level: int) -> float:
	var lv := clampi(jet_level, 1, 20)
	return max_speed_mps * (1.0 + (lv - 1) * 0.012)

func get_scaled_thrust_kn(jet_level: int, afterburning: bool) -> float:
	var lv := clampi(jet_level, 1, 20)
	var base_kn := afterburner_thrust_kn if afterburning else dry_thrust_kn
	return base_kn * (1.0 + (lv - 1) * 0.015)

func get_scaled_pitch_rate(jet_level: int) -> float:
	var lv := clampi(jet_level, 1, 20)
	var trait_bonus := 0.0
	for t in passive_traits:
		trait_bonus += t.turn_rate_bonus
	return pitch_rate_deg * (1.0 + trait_bonus) * (1.0 + (lv - 1) * 0.011)

func get_effective_detection_km(jet_level: int, rockets_mounted: bool) -> float:
	var lv := clampi(jet_level, 1, 20)
	var rcs_reduction := 0.0
	for t in passive_traits:
		rcs_reduction += t.stealth_rcs_reduction
	var penalty := 0.15 if rockets_mounted else 0.0
	var stealth_factor := clampf(1.0 - rcs_reduction * 0.5 + penalty, 0.32, 1.25)
	return detection_range_km * stealth_factor / (1.0 + (lv - 1) * 0.008)
