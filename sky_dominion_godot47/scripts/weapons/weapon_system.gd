class_name WeaponSystem
extends Node
## Manages Missiles (Primary, Secondary, Nuclear), Rocket Pods, Cannons,
## Flares, Lock-On Cone Scanning, and RWR Incoming Threat Tracking.

signal lock_progress_changed(target: Node3D, progress: float, is_locked: bool, weapon_slot: String)
signal ammo_changed(snapshot: Dictionary)
signal rwr_warning(incoming_missiles: Array[Node3D], nuclear_alert: bool)
signal flare_deployed(remaining: int)

var owner_jet: FighterController
var aircraft_spec: AircraftData

var cannon_spec: WeaponData.CannonSpec
var primary_missile_spec: WeaponData.MissileSpec
var secondary_missile_spec: WeaponData.MissileSpec
var nuclear_missile_spec: WeaponData.MissileSpec
var rocket_spec: WeaponData.RocketSpec
var flare_spec: WeaponData.FlareSpec

# Ammunition & Cooldowns
var cannon_ammo: int = 0
var cannon_heat: float = 0.0
var cannon_overheated: bool = false
var _cannon_fire_timer: float = 0.0
var _cannon_spin_timer: float = 0.0

var active_missile_slot: String = "primary"  ## "primary" | "secondary" | "nuclear"
var primary_ammo: int = 0
var secondary_ammo: int = 0
var nuclear_ammo: int = 0
var rocket_ammo: int = 0
var flare_ammo: int = 0

var _primary_reload_timer: float = 0.0
var _secondary_reload_timer: float = 0.0
var _nuclear_reload_timer: float = 0.0
var _rocket_reload_timer: float = 0.0
var _rocket_salvo_timer: float = 0.0
var _flare_cooldown_timer: float = 0.0
var _flare_active_timer: float = 0.0
var _flare_reload_timer: float = 0.0

# Targeting & Incoming Threats
var current_target: FighterController = null
var lock_progress: float = 0.0
var is_locked: bool = false
var airborne_missiles_by_slot: Dictionary = {"primary": [], "secondary": [], "nuclear": []}
var incoming_threats: Array[Node3D] = []

func configure_from_aircraft(jet: FighterController, spec: AircraftData, mount_rockets: bool) -> void:
	owner_jet = jet
	aircraft_spec = spec

	cannon_spec = GameDatabase.get_cannon(spec.cannon_id)
	primary_missile_spec = GameDatabase.get_missile(spec.primary_missile_id)
	secondary_missile_spec = GameDatabase.get_missile(spec.secondary_missile_id) if spec.secondary_missile_id != "" else null
	nuclear_missile_spec = GameDatabase.get_missile(spec.nuclear_missile_id) if spec.nuclear_missile_id != "" else null
	rocket_spec = GameDatabase.get_rocket(spec.rocket_id) if (mount_rockets and spec.can_equip_rockets and spec.rocket_id != "") else null
	flare_spec = spec.flare_spec

	cannon_ammo = cannon_spec.magazine_capacity if cannon_spec else 0
	primary_ammo = spec.primary_missile_count
	secondary_ammo = spec.secondary_missile_count
	nuclear_ammo = spec.nuclear_missile_count
	rocket_ammo = spec.rocket_count if rocket_spec else 0
	flare_ammo = flare_spec.capacity if flare_spec else 0
	_emit_ammo_snapshot()

func _process(delta: float) -> void:
	if owner_jet == null or aircraft_spec == null or owner_jet.current_hp <= 0.0:
		return

	_update_reloads_and_heat(delta)
	_update_target_lock(delta)
	_update_rwr_threats()

	if owner_jet.is_player:
		_handle_player_weapon_input(delta)

func _handle_player_weapon_input(delta: float) -> void:
	if Input.is_action_just_pressed("cycle_missile"):
		_cycle_missile_slot()
	if Input.is_action_just_pressed("cycle_target"):
		_select_best_target(true)
	if Input.is_action_just_pressed("deploy_flare"):
		deploy_flares()
	if Input.is_action_just_pressed("fire_missile"):
		fire_selected_missile()
	if Input.is_action_just_pressed("fire_nuclear"):
		fire_missile_by_slot("nuclear")
	if Input.is_action_pressed("fire_rocket"):
		_rocket_salvo_timer -= delta
		if _rocket_salvo_timer <= 0.0 and fire_rockets():
			_rocket_salvo_timer = 1.0 / maxf(1.0, rocket_spec.salvo_rate_rps)
	if Input.is_action_pressed("fire_cannon"):
		fire_cannon(delta)
	else:
		_cannon_spin_timer = 0.0

func _update_reloads_and_heat(delta: float) -> void:
	if cannon_spec:
		var cool_mult := 1.0 if not cannon_overheated else 0.75
		cannon_heat = maxf(0.0, cannon_heat - cannon_spec.cool_rate_per_sec * cool_mult * delta)
		if cannon_overheated and cannon_heat <= 0.20:
			cannon_overheated = false
	_cannon_fire_timer = maxf(0.0, _cannon_fire_timer - delta)

	if primary_missile_spec and primary_ammo < aircraft_spec.primary_missile_count:
		_primary_reload_timer += delta
		if _primary_reload_timer >= _get_reload_time(primary_missile_spec.reload_time_sec):
			_primary_reload_timer = 0.0
			primary_ammo += 1
			_emit_ammo_snapshot()

	if secondary_missile_spec and secondary_ammo < aircraft_spec.secondary_missile_count:
		_secondary_reload_timer += delta
		if _secondary_reload_timer >= _get_reload_time(secondary_missile_spec.reload_time_sec):
			_secondary_reload_timer = 0.0
			secondary_ammo += 1
			_emit_ammo_snapshot()

	if nuclear_missile_spec and nuclear_ammo < aircraft_spec.nuclear_missile_count:
		_nuclear_reload_timer += delta
		if _nuclear_reload_timer >= nuclear_missile_spec.reload_time_sec:
			_nuclear_reload_timer = 0.0
			nuclear_ammo += 1
			_emit_ammo_snapshot()

	if rocket_spec and rocket_ammo < aircraft_spec.rocket_count:
		_rocket_reload_timer += delta
		if _rocket_reload_timer >= rocket_spec.reload_time_sec:
			_rocket_reload_timer = 0.0
			rocket_ammo = aircraft_spec.rocket_count
			_emit_ammo_snapshot()

	if _flare_cooldown_timer > 0.0:
		_flare_cooldown_timer = maxf(0.0, _flare_cooldown_timer - delta)
	if _flare_active_timer > 0.0:
		_flare_active_timer = maxf(0.0, _flare_active_timer - delta)
	if flare_spec and flare_ammo < flare_spec.capacity:
		_flare_reload_timer += delta
		if _flare_reload_timer >= flare_spec.reload_time_sec:
			_flare_reload_timer = 0.0
			flare_ammo += 1
			_emit_ammo_snapshot()

func _get_reload_time(base_t: float) -> float:
	var bonus := 0.0
	for t in aircraft_spec.passive_traits:
		bonus += t.lock_speed_bonus
	return base_t / (1.0 + bonus * 0.5)

func _update_target_lock(delta: float) -> void:
	if owner_jet.emp_timer > 0.0:
		reset_all_locks()
		return

	if current_target == null or not is_instance_valid(current_target) or current_target.current_hp <= 0.0:
		_select_best_target(false)

	var m_spec := _get_slot_spec(active_missile_slot)
	if m_spec == null or current_target == null:
		lock_progress = 0.0
		is_locked = false
		lock_progress_changed.emit(null, 0.0, false, active_missile_slot)
		return

	var to_target := current_target.global_position - owner_jet.global_position
	var dist_m := to_target.length()
	var angle_deg := rad_to_deg((-owner_jet.global_transform.basis.z).angle_to(to_target.normalized()))

	# Check stealth detection envelope & 360 DAS trait
	var max_lock_dist := minf(m_spec.max_range_m, current_target.get_effective_detection_range_m() * 1.8)
	var cone := m_spec.lock_cone_deg
	for t in aircraft_spec.passive_traits:
		if t.id in ["das_360", "eodas_360"]:
			cone *= 1.35

	if dist_m <= max_lock_dist and angle_deg <= cone:
		var m_lv := UpgradeManager.get_missile_level(m_spec.id)
		var lock_dur := m_spec.get_scaled_lock_time(m_lv)
		var speed_mult := 1.0
		for t in aircraft_spec.passive_traits:
			speed_mult += t.lock_speed_bonus
		if owner_jet.ability_active and aircraft_spec.special_ability.effect_tag in ["apex_overdrive", "rapid_salvo"]:
			speed_mult *= 2.0
		lock_progress = minf(1.0, lock_progress + (delta * speed_mult) / maxf(0.15, lock_dur))
		is_locked = lock_progress >= 1.0
	else:
		lock_progress = maxf(0.0, lock_progress - delta * 1.4)
		is_locked = false

	lock_progress_changed.emit(current_target, lock_progress, is_locked, active_missile_slot)

func _select_best_target(force_next: bool) -> void:
	var candidates: Array[FighterController] = []
	for node in get_tree().get_nodes_in_group("aircraft"):
		if node is FighterController and node != owner_jet and node.team_id != owner_jet.team_id and node.current_hp > 0.0:
			candidates.append(node)
	if candidates.is_empty():
		current_target = null
		return
	if force_next and current_target in candidates:
		var idx := (candidates.find(current_target) + 1) % candidates.size()
		current_target = candidates[idx]
		lock_progress = 0.0
		is_locked = false
		return
	var forward := -owner_jet.global_transform.basis.z
	candidates.sort_custom(func(a: FighterController, b: FighterController) -> bool:
		var ang_a := forward.angle_to((a.global_position - owner_jet.global_position).normalized())
		var ang_b := forward.angle_to((b.global_position - owner_jet.global_position).normalized())
		return ang_a < ang_b
	)
	current_target = candidates[0]

func _cycle_missile_slot() -> void:
	var order: Array[String] = ["primary"]
	if secondary_missile_spec:
		order.append("secondary")
	if nuclear_missile_spec:
		order.append("nuclear")
	var idx := (order.find(active_missile_slot) + 1) % order.size()
	active_missile_slot = order[idx]
	lock_progress = 0.0
	is_locked = false

func fire_selected_missile() -> bool:
	return fire_missile_by_slot(active_missile_slot)

func fire_missile_by_slot(slot: String) -> bool:
	var m_spec := _get_slot_spec(slot)
	if m_spec == null or current_target == null or not is_locked:
		return false

	# Clean invalid airborne refs
	var airborne: Array = airborne_missiles_by_slot[slot].filter(func(n: Variant) -> bool: return is_instance_valid(n))
	airborne_missiles_by_slot[slot] = airborne

	var max_air := m_spec.max_simultaneous_airborne
	if owner_jet.ability_active and aircraft_spec.special_ability.effect_tag == "missile_barrage":
		max_air = maxi(max_air, 4)

	if airborne.size() >= max_air or _get_slot_ammo(slot) <= 0:
		return false

	_consume_slot_ammo(slot)
	var missile := MissileProjectile.new()
	get_tree().current_scene.add_child(missile)
	var spawn_pos := owner_jet.global_position - owner_jet.global_transform.basis.y * 1.4 - owner_jet.global_transform.basis.z * 2.5
	missile.launch(owner_jet, current_target, m_spec, UpgradeManager.get_missile_level(m_spec.id), spawn_pos, owner_jet.global_transform.basis)
	airborne.append(missile)

	if owner_jet.vfx_audio:
		owner_jet.vfx_audio.play_missile_launch_sfx(m_spec)
	_emit_ammo_snapshot()
	return true

func fire_rockets() -> bool:
	if rocket_spec == null or rocket_ammo <= 0:
		return false
	rocket_ammo -= 1
	var rocket := RocketProjectile.new()
	get_tree().current_scene.add_child(rocket)
	var wing_side := -1.0 if (rocket_ammo % 2 == 0) else 1.0
	var spawn_pos := owner_jet.global_position + owner_jet.global_transform.basis.x * (3.2 * wing_side) - owner_jet.global_transform.basis.z * 2.0
	var r_lv := UpgradeManager.get_rocket_level(rocket_spec.id)
	var rad_bonus := 1.25 if (owner_jet.ability_active and aircraft_spec.special_ability.effect_tag == "armor_brace") else 1.0
	rocket.launch(owner_jet, current_target, rocket_spec, r_lv, rad_bonus, spawn_pos, owner_jet.global_transform.basis)
	if owner_jet.vfx_audio:
		owner_jet.vfx_audio.play_rocket_launch_sfx(rocket_spec)
	_emit_ammo_snapshot()
	return true

func fire_cannon(delta: float) -> void:
	if cannon_spec == null or cannon_overheated or cannon_ammo <= 0:
		return
	_cannon_spin_timer += delta
	if _cannon_spin_timer < cannon_spec.spin_up_sec:
		return
	if _cannon_fire_timer > 0.0:
		return

	var c_lv := UpgradeManager.get_cannon_level(cannon_spec.id)
	_cannon_fire_timer = 60.0 / float(cannon_spec.rpm)
	cannon_ammo -= 1
	cannon_heat += cannon_spec.heat_per_shot / cannon_spec.get_scaled_overheat_factor(c_lv)
	if cannon_heat >= 1.0:
		cannon_heat = 1.0
		cannon_overheated = true

	var round_node := CannonProjectile.new()
	get_tree().current_scene.add_child(round_node)
	var muzzle_pos := owner_jet.global_position - owner_jet.global_transform.basis.z * 4.2 + owner_jet.global_transform.basis.x * 0.45
	round_node.fire(owner_jet, cannon_spec, c_lv, muzzle_pos, owner_jet.global_transform.basis)

	if owner_jet.vfx_audio:
		owner_jet.vfx_audio.play_cannon_shot_sfx(cannon_spec)
	_emit_ammo_snapshot()

func deploy_flares() -> bool:
	if flare_spec == null or flare_ammo <= 0 or _flare_cooldown_timer > 0.0:
		return false
	flare_ammo -= 1
	_flare_cooldown_timer = flare_spec.cooldown_sec
	_flare_active_timer = flare_spec.active_duration_sec

	# Spawn decoy flare burst behind aircraft
	for i in range(flare_spec.pellets_per_burst):
		var decoy := FlareCountermeasure.new()
		get_tree().current_scene.add_child(decoy)
		var side := -1.0 if (i % 2 == 0) else 1.0
		var eject_dir := (owner_jet.global_transform.basis.x * side + -owner_jet.global_transform.basis.y * 0.65 + owner_jet.global_transform.basis.z * 0.4).normalized()
		decoy.deploy(owner_jet, flare_spec, owner_jet.global_position, eject_dir * 45.0 + owner_jet.velocity * 0.5)

	# Attempt immediate spoof against incoming missiles
	for m in incoming_threats:
		if is_instance_valid(m) and m is MissileProjectile:
			m.evaluate_flare_decoy(flare_spec, owner_jet.get_flare_spoof_bonus())

	if owner_jet.vfx_audio:
		owner_jet.vfx_audio.play_flare_sfx()
	flare_deployed.emit(flare_ammo)
	_emit_ammo_snapshot()
	return true

func refill_flares() -> void:
	if flare_spec:
		flare_ammo = flare_spec.capacity
		_flare_cooldown_timer = 0.0
		_emit_ammo_snapshot()

func break_incoming_locks() -> void:
	for m in incoming_threats:
		if is_instance_valid(m) and m is MissileProjectile:
			m.spoofed = true

func reset_all_locks() -> void:
	lock_progress = 0.0
	is_locked = false

func _update_rwr_threats() -> void:
	incoming_threats.clear()
	var has_nuke := false
	for node in get_tree().get_nodes_in_group("active_missiles"):
		if node is MissileProjectile and node.target == owner_jet and not node.spoofed:
			incoming_threats.append(node)
			if node.missile_spec and node.missile_spec.is_nuclear:
				has_nuke = true
	rwr_warning.emit(incoming_threats, has_nuke)

func _get_slot_spec(slot: String) -> WeaponData.MissileSpec:
	match slot:
		"primary": return primary_missile_spec
		"secondary": return secondary_missile_spec
		"nuclear": return nuclear_missile_spec
	return null

func _get_slot_ammo(slot: String) -> int:
	match slot:
		"primary": return primary_ammo
		"secondary": return secondary_ammo
		"nuclear": return nuclear_ammo
	return 0

func _consume_slot_ammo(slot: String) -> void:
	match slot:
		"primary": primary_ammo = maxi(0, primary_ammo - 1)
		"secondary": secondary_ammo = maxi(0, secondary_ammo - 1)
		"nuclear": nuclear_ammo = maxi(0, nuclear_ammo - 1)

func _emit_ammo_snapshot() -> void:
	ammo_changed.emit({
		"cannon": cannon_ammo,
		"cannon_heat": cannon_heat,
		"primary": primary_ammo,
		"secondary": secondary_ammo,
		"nuclear": nuclear_ammo,
		"rockets": rocket_ammo,
		"flares": flare_ammo,
		"active_slot": active_missile_slot,
	})
