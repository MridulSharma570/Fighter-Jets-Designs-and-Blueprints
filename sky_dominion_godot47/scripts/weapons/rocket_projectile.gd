class_name RocketProjectile
extends Node3D
## Podded Rocket Projectile (Unguided Salvo & Laser Semi-Guided APKWS/LOGIR).

var owner_jet: FighterController
var target: FighterController
var rocket_spec: WeaponData.RocketSpec
var rocket_level: int = 1
var radius_bonus: float = 1.0

var velocity_vec: Vector3 = Vector3.ZERO
var distance_traveled: float = 0.0

func launch(shooter: FighterController, tgt: FighterController, spec: WeaponData.RocketSpec,
		level: int, rad_bonus: float, spawn_pos: Vector3, start_basis: Basis) -> void:
	owner_jet = shooter
	target = tgt
	rocket_spec = spec
	rocket_level = level
	radius_bonus = rad_bonus
	global_position = spawn_pos

	var disp_rad := deg_to_rad(spec.get_scaled_dispersion(level))
	var dir := (-start_basis.z + start_basis.x * randf_range(-disp_rad, disp_rad) + start_basis.y * randf_range(-disp_rad, disp_rad)).normalized()
	velocity_vec = dir * spec.speed_mps
	look_at(global_position + dir, Vector3.UP)

	var visual := OrdnanceMeshBuilder.build_rocket_visual(spec)
	add_child(visual)

func _physics_process(delta: float) -> void:
	if rocket_spec == null:
		return
	# Mild semi-active laser homing for APKWS II / LOGIR
	if rocket_spec.guidance == WeaponData.RocketGuidance.LASER_SEMI_GUIDED and target != null and is_instance_valid(target):
		var to_tgt := (target.global_position - global_position).normalized()
		var cur := velocity_vec.normalized()
		if rad_to_deg(cur.angle_to(to_tgt)) <= 16.0:
			velocity_vec = cur.slerp(to_tgt, clampf(1.8 * delta, 0.0, 1.0)) * rocket_spec.speed_mps

	var step := velocity_vec * delta
	global_position += step
	distance_traveled += step.length()

	for node in get_tree().get_nodes_in_group("aircraft"):
		if node is FighterController and node != owner_jet and node.current_hp > 0.0:
			if global_position.distance_to(node.global_position) <= 10.0:
				_detonate()
				return

	if distance_traveled >= rocket_spec.max_range_m:
		_detonate()

func _detonate() -> void:
	var dmg := rocket_spec.get_scaled_damage(rocket_level)
	var splash := rocket_spec.get_scaled_splash(rocket_level) * radius_bonus
	for node in get_tree().get_nodes_in_group("aircraft"):
		if node is FighterController and node != owner_jet and node.current_hp > 0.0:
			var d := global_position.distance_to(node.global_position)
			if d <= splash:
				node.apply_damage(dmg * (1.0 - (d / splash) * 0.5), owner_jet, true)
	queue_free()
