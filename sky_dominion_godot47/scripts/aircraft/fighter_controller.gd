class_name FighterController
extends CharacterBody3D
## Physically Grounded 6-DOF Fighter Jet Controller for Godot 4.7.
## Uses real atmospheric air-density rho(h), Lift/Drag polars (parasitic + transonic wave + induced drag),
## thrust-to-weight kinematics, corner-speed turn energy bleed, and Overdrive abilities.

signal health_changed(current_hp: float, max_hp: float)
signal ability_state_changed(active: bool, remaining_sec: float, cooldown_sec: float)
signal emp_interference(duration_sec: float)
signal jet_destroyed(attacker: Node3D)

@export var jet_id: String = "s_57_felonis"
@export var is_player: bool = true
@export var team_id: int = 0
@export var mount_rocket_pods: bool = true

var spec: AircraftData
var jet_level: int = 1
var ability_level: int = 1

var current_hp: float = 175.0
var max_hp: float = 175.0
var current_speed: float = 350.0
var throttle: float = 0.70
var fuel: float = 100.0
var max_fuel: float = 100.0
var is_afterburning: bool = false
var g_force: float = 1.0
var aoa_deg: float = 0.0
var mach_number: float = 1.0

var ability_active: bool = false
var ability_timer: float = 0.0
var ability_cooldown_timer: float = 0.0
var emp_timer: float = 0.0
var damage_shield_factor: float = 0.0
var stealth_cloak_factor: float = 0.0

@onready var weapon_system: WeaponSystem = get_node_or_null("WeaponSystem")
@onready var vfx_audio: AircraftVfxAudio = get_node_or_null("AircraftVfxAudio")
@onready var visual_root: Node3D = get_node_or_null("VisualRoot")

var _prev_velocity: Vector3 = Vector3.ZERO
var _cobra_pitch_accum: float = 0.0

func _ready() -> void:
	initialize_jet(jet_id)

func initialize_jet(new_jet_id: String) -> void:
	jet_id = new_jet_id
	spec = GameDatabase.get_jet(jet_id)
	if spec == null:
		push_error("FighterController: Unknown jet_id '%s'" % jet_id)
		return
	jet_level = UpgradeManager.get_jet_level(jet_id)
	ability_level = UpgradeManager.get_ability_level(jet_id)
	max_hp = spec.get_scaled_hp(jet_level)
	current_hp = max_hp
	current_speed = spec.cruise_speed_mps
	velocity = -global_transform.basis.z * current_speed
	_prev_velocity = velocity

	if weapon_system:
		weapon_system.configure_from_aircraft(self, spec, mount_rocket_pods)
	if vfx_audio:
		vfx_audio.configure_from_aircraft(spec)
	health_changed.emit(current_hp, max_hp)

func _physics_process(delta: float) -> void:
	if spec == null or current_hp <= 0.0:
		return

	_update_timers(delta)
	_handle_aerodynamic_flight(delta)
	move_and_slide()

	var accel_vec := (velocity - _prev_velocity) / maxf(delta, 0.001)
	_prev_velocity = velocity
	g_force = clampf(accel_vec.length() / 9.81 + 1.0, 0.1, spec.max_g_limit + 2.5)

	if vfx_audio:
		vfx_audio.update_flight_telemetry(current_speed, spec.max_speed_mps, is_afterburning, g_force, aoa_deg)

func _update_timers(delta: float) -> void:
	if emp_timer > 0.0:
		emp_timer = maxf(0.0, emp_timer - delta)
	if ability_active:
		ability_timer -= delta
		if ability_timer <= 0.0:
			_end_special_ability()
	elif ability_cooldown_timer > 0.0:
		ability_cooldown_timer = maxf(0.0, ability_cooldown_timer - delta)

	if ability_active or ability_cooldown_timer > 0.0:
		ability_state_changed.emit(ability_active, maxf(0.0, ability_timer), maxf(0.0, ability_cooldown_timer))

func _handle_aerodynamic_flight(delta: float) -> void:
	var pitch_in := 0.0
	var roll_in := 0.0
	var yaw_in := 0.0

	if is_player:
		pitch_in = Input.get_axis("pitch_down", "pitch_up")
		roll_in = Input.get_axis("roll_right", "roll_left")
		yaw_in = Input.get_axis("yaw_right", "yaw_left")
		if Input.is_action_pressed("throttle_up"):
			throttle = minf(1.25, throttle + 0.65 * delta)
		elif Input.is_action_pressed("throttle_down"):
			throttle = maxf(0.15, throttle - 0.65 * delta)
		if Input.is_action_just_pressed("activate_ability"):
			trigger_special_ability()

	var supercruise := _has_supercruise_trait()
	is_afterburning = throttle > 0.95 and fuel > 1.0
	if ability_active and spec.special_ability.effect_tag in ["reheat_surge", "cobra_boost", "apex_overdrive"]:
		is_afterburning = true

	if is_afterburning and not (supercruise and throttle <= 1.02):
		fuel = maxf(0.0, fuel - 14.0 * delta)
		if fuel <= 0.0:
			throttle = minf(throttle, 0.90)
	else:
		fuel = minf(max_fuel, fuel + (max_fuel / spec.fuel_regen_sec) * delta)

	# --- Real Atmospheric & Aerodynamic Polar Physics ---
	var alt_m := maxf(0.0, global_position.y)
	var rho := 1.225 * exp(-alt_m / 8500.0) # ISA air density (kg/m^3)
	var speed_of_sound := lerpf(340.3, 295.1, clampf(alt_m / 11000.0, 0.0, 1.0))
	mach_number = current_speed / speed_of_sound

	# Thrust in Newtons scaled by air density^0.65 and throttle
	var max_thrust_n := spec.get_scaled_thrust_kn(jet_level, is_afterburning) * 1000.0
	var density_ratio := pow(rho / 1.225, 0.65)
	var thrust_n := max_thrust_n * clampf(throttle, 0.1, 1.25) * density_ratio
	if ability_active and spec.special_ability.effect_tag == "reheat_surge":
		thrust_n *= 1.35
	elif ability_active and spec.special_ability.effect_tag == "cobra_boost":
		thrust_n *= 1.75

	# Dynamic Pressure q = 0.5 * rho * v^2
	var q_dyn := 0.5 * rho * current_speed * current_speed
	var nose_dir := -global_transform.basis.z
	if velocity.length() > 1.0:
		aoa_deg = rad_to_deg(nose_dir.angle_to(velocity.normalized()))

	# Lift Coefficient & Induced Drag Polar (C_D = C_D0 + C_D_wave + C_L^2 / (pi * e * AR))
	var cl := clampf(deg_to_rad(aoa_deg + 2.0) * 3.8, -1.6, 1.8)
	var wave_drag := 0.0
	if mach_number > 0.88 and mach_number < 1.25:
		wave_drag = 0.022 * sin(PI * clampf((mach_number - 0.88) / 0.37, 0.0, 1.0))
	var k_induced := 1.0 / (PI * spec.oswald_efficiency * spec.aspect_ratio)
	var cd_total := spec.zero_lift_drag_cd0 + wave_drag + k_induced * cl * cl
	var drag_n := q_dyn * spec.wing_area_m2 * cd_total

	# Gravity flight-path component: -m * g * sin(flight_path_angle)
	var gravity_n := spec.combat_mass_kg * 9.81 * nose_dir.y
	var net_force_n := thrust_n - drag_n - gravity_n
	var long_accel := net_force_n / spec.combat_mass_kg

	var max_spd := spec.get_scaled_max_speed(jet_level)
	current_speed = clampf(current_speed + long_accel * delta, spec.stall_speed_mps * 0.8, max_spd)

	# Authority scales with dynamic pressure up to corner speed (with TVC maintaining control at low speed)
	var aero_authority := clampf(current_speed / 190.0, 0.25, 1.15)
	if spec.has_thrust_vectoring:
		aero_authority = maxf(aero_authority, 0.72)

	var pitch_rate := spec.get_scaled_pitch_rate(jet_level) * aero_authority
	var roll_rate := spec.roll_rate_deg * aero_authority
	var yaw_rate := spec.yaw_rate_deg * aero_authority

	if ability_active and spec.special_ability.effect_tag in ["cobra_boost", "kulbit_break", "apex_overdrive", "spectra_ghost"]:
		pitch_rate *= 1.35
		roll_rate *= 1.25
		yaw_rate *= 1.40

	if ability_active and spec.special_ability.effect_tag == "kulbit_break" and _cobra_pitch_accum < 360.0:
		var flip_step := 260.0 * delta
		_cobra_pitch_accum += flip_step
		rotate_object_local(Vector3.RIGHT, deg_to_rad(flip_step))
	else:
		rotate_object_local(Vector3.RIGHT, deg_to_rad(pitch_in * pitch_rate * delta))
		rotate_object_local(Vector3.FORWARD, deg_to_rad(roll_in * roll_rate * delta))
		rotate_object_local(Vector3.UP, deg_to_rad(yaw_in * yaw_rate * delta))

	var align_rate := 5.5 if spec.has_thrust_vectoring else 3.8
	velocity = velocity.lerp(nose_dir * current_speed, clampf(align_rate * delta, 0.0, 1.0))

func trigger_special_ability() -> bool:
	if spec == null or spec.special_ability == null:
		return false
	if ability_active or ability_cooldown_timer > 0.0 or emp_timer > 0.0:
		return false

	var ab := spec.special_ability
	ability_active = true
	ability_timer = ab.duration_sec
	_cobra_pitch_accum = 0.0

	match ab.effect_tag:
		"flare_reload_cloak":
			if weapon_system:
				weapon_system.refill_flares()
			stealth_cloak_factor = 0.70
		"reheat_surge":
			fuel = max_fuel
		"armor_brace":
			damage_shield_factor = 0.40
		"spectra_ghost", "ew_jammer":
			_broadcast_ew_pulse(4500.0 if ab.effect_tag == "ew_jammer" else 2800.0)
		"kulbit_break":
			if weapon_system:
				weapon_system.break_incoming_locks()

	if vfx_audio:
		vfx_audio.play_ability_sfx(ab.effect_tag)
	ability_state_changed.emit(true, ability_timer, 0.0)
	return true

func _end_special_ability() -> void:
	ability_active = false
	ability_timer = 0.0
	damage_shield_factor = 0.0
	stealth_cloak_factor = 0.0
	ability_cooldown_timer = spec.special_ability.get_cooldown(ability_level)
	ability_state_changed.emit(false, 0.0, ability_cooldown_timer)

func _broadcast_ew_pulse(radius_m: float) -> void:
	for node in get_tree().get_nodes_in_group("aircraft"):
		if node == self or not (node is FighterController):
			continue
		if node.team_id != team_id and global_position.distance_to(node.global_position) <= radius_m:
			node.apply_emp(3.0)

func apply_emp(duration_sec: float) -> void:
	emp_timer = maxf(emp_timer, duration_sec)
	if weapon_system:
		weapon_system.reset_all_locks()
	emp_interference.emit(duration_sec)

func apply_damage(amount: float, attacker: Node3D = null, is_cannon_or_shrapnel: bool = false) -> void:
	if current_hp <= 0.0:
		return
	var mitigation := spec.armor_rating
	if is_cannon_or_shrapnel:
		for t in spec.passive_traits:
			mitigation += t.armor_damage_reduction
	mitigation = clampf(mitigation + damage_shield_factor, 0.0, 0.80)

	var final_dmg := amount * (1.0 - mitigation)
	current_hp = maxf(0.0, current_hp - final_dmg)
	health_changed.emit(current_hp, max_hp)

	if current_hp <= 0.0:
		if vfx_audio:
			vfx_audio.play_explosion_vfx(global_position, false)
		jet_destroyed.emit(attacker)

func get_effective_detection_range_m() -> float:
	if spec == null:
		return 4500.0
	var pods_active := mount_rocket_pods and spec.can_equip_rockets and weapon_system and weapon_system.rocket_ammo > 0
	var base_m := spec.get_effective_detection_km(jet_level, pods_active) * 1000.0
	return base_m * (1.0 - stealth_cloak_factor)

func get_flare_spoof_bonus() -> float:
	var bonus := 0.0
	if spec:
		for t in spec.passive_traits:
			bonus += t.flare_spoof_bonus
	return bonus

func _has_supercruise_trait() -> bool:
	if spec == null:
		return false
	for t in spec.passive_traits:
		if t.enables_supercruise:
			return true
	return false
