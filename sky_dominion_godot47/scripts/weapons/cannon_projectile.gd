class_name CannonProjectile
extends Node3D
## High-Velocity Aircraft Cannon Tracer Round (20mm, 23mm, 25mm, 27mm, 30mm).

var owner_jet: FighterController
var cannon_spec: WeaponData.CannonSpec
var cannon_level: int = 1
var velocity_vec: Vector3 = Vector3.ZERO
var distance_traveled: float = 0.0

func fire(shooter: FighterController, spec: WeaponData.CannonSpec, level: int,
		spawn_pos: Vector3, start_basis: Basis) -> void:
	owner_jet = shooter
	cannon_spec = spec
	cannon_level = level
	global_position = spawn_pos

	var spread_rad := deg_to_rad(spec.spread_deg)
	var dir := (-start_basis.z + start_basis.x * randf_range(-spread_rad, spread_rad) + start_basis.y * randf_range(-spread_rad, spread_rad)).normalized()
	velocity_vec = dir * spec.muzzle_velocity_mps + shooter.velocity * 0.35

	var mesh_inst := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.04; cap.height = 1.6
	mesh_inst.mesh = cap
	mesh_inst.rotation_degrees.x = 90.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = spec.tracer_color
	mat.emission_enabled = true
	mat.emission = spec.tracer_color
	mat.emission_energy_multiplier = 4.0
	mesh_inst.material_override = mat
	add_child(mesh_inst)
	look_at(global_position + dir, Vector3.UP)

func _physics_process(delta: float) -> void:
	if cannon_spec == null:
		return
	var step := velocity_vec * delta
	global_position += step
	distance_traveled += step.length()

	var dmg := cannon_spec.get_scaled_damage(cannon_level)
	for node in get_tree().get_nodes_in_group("aircraft"):
		if node is FighterController and node != owner_jet and node.current_hp > 0.0:
			if global_position.distance_to(node.global_position) <= 6.5:
				node.apply_damage(dmg, owner_jet, true)
				queue_free()
				return

	# Allow shooting down incoming destructible nuclear warheads!
	for m in get_tree().get_nodes_in_group("active_missiles"):
		if m is MissileProjectile and m.missile_spec.destructible_in_flight:
			if global_position.distance_to(m.global_position) <= 8.0:
				m.intercept_damage(dmg)
				queue_free()
				return

	if distance_traveled >= cannon_spec.effective_range_m:
		queue_free()
