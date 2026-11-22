class_name MissileProjectile
extends Node3D
## Guided Missile & Tactical Nuclear Warhead projectile for Godot 4.7.
## Implements Proportional Navigation homing, Flare/Chaff countermeasure evaluation,
## destructible nuclear warhead interception, and EMP + Nuclear thermal blast.

var owner_jet: FighterController
var target: FighterController
var missile_spec: WeaponData.MissileSpec
var missile_level: int = 1

var velocity_vec: Vector3 = Vector3.ZERO
var distance_traveled: float = 0.0
var warhead_hp: float = 40.0
var spoofed: bool = false
var _detonated: bool = false
var _trail_particles: GPUParticles3D

func _ready() -> void:
	add_to_group("active_missiles")

func launch(shooter: FighterController, tgt: FighterController, spec: WeaponData.MissileSpec,
		level: int, spawn_pos: Vector3, start_basis: Basis) -> void:
	owner_jet = shooter
	target = tgt
	missile_spec = spec
	missile_level = level
	warhead_hp = spec.warhead_hp
	global_position = spawn_pos
	global_transform.basis = start_basis
	velocity_vec = -start_basis.z * spec.speed_mps
	_build_visual_mesh_and_plume()

func _build_visual_mesh_and_plume() -> void:
	var visual := OrdnanceMeshBuilder.build_missile_visual(missile_spec)
	add_child(visual)

	_trail_particles = GPUParticles3D.new()
	_trail_particles.amount = 64 if missile_spec.is_nuclear else 36
	_trail_particles.lifetime = 1.6
	var pmat := ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 0, 1)
	pmat.spread = 8.0
	pmat.initial_velocity_min = 15.0
	pmat.initial_velocity_max = 32.0
	pmat.color = missile_spec.plume_color
	_trail_particles.process_material = pmat
	var quad := QuadMesh.new()
	quad.size = Vector2(0.9, 0.9)
	_trail_particles.draw_pass_1 = quad
	add_child(_trail_particles)

func _physics_process(delta: float) -> void:
	if _detonated or missile_spec == null:
		return

	if not spoofed and target != null and is_instance_valid(target) and target.current_hp > 0.0:
		var to_tgt := target.global_position - global_position
		var dist := to_tgt.length()
		if dist <= missile_spec.proximity_fuze_m:
			_detonate()
			return

		# Lead pursuit / proportional guidance
		var intercept_time := dist / maxf(100.0, missile_spec.speed_mps)
		var predicted_pos := target.global_position + target.velocity * intercept_time * 0.65
		var desired_dir := (predicted_pos - global_position).normalized()
		var cur_dir := velocity_vec.normalized()
		var turn_rad := deg_to_rad(missile_spec.get_scaled_turn_rate(missile_level) * delta)
		if owner_jet and owner_jet.ability_active and owner_jet.spec.special_ability.effect_tag == "missile_barrage":
			turn_rad *= 1.25
		var new_dir := cur_dir.slerp(desired_dir, clampf(turn_rad / maxf(0.01, cur_dir.angle_to(desired_dir)), 0.0, 1.0))
		velocity_vec = new_dir * missile_spec.speed_mps
		look_at(global_position + new_dir, Vector3.UP)

	var step := velocity_vec * delta
	global_position += step
	distance_traveled += step.length()
	if distance_traveled >= missile_spec.max_range_m:
		_detonate()

func evaluate_flare_decoy(flare: WeaponData.FlareSpec, defender_bonus: float) -> void:
	if spoofed or missile_spec == null:
		return
	var decoy_power := flare.ir_spoof_power if missile_spec.guidance == WeaponData.GuidanceType.INFRARED else flare.radar_chaff_power
	var resist := missile_spec.get_scaled_flare_resistance(missile_level)
	var spoof_chance := clampf(decoy_power + defender_bonus - resist, 0.05, 0.95)
	if randf() <= spoof_chance:
		spoofed = true
		velocity_vec = (velocity_vec.normalized() + Vector3(randf_range(-0.35, 0.35), -0.25, randf_range(-0.35, 0.35))).normalized() * missile_spec.speed_mps

func intercept_damage(dmg: float) -> void:
	if not missile_spec.destructible_in_flight or _detonated:
		return
	warhead_hp -= dmg
	if warhead_hp <= 0.0:
		_detonated = true
		queue_free()

func _detonate() -> void:
	if _detonated:
		return
	_detonated = true

	var base_dmg := missile_spec.get_scaled_damage(missile_level)
	var blast_r := missile_spec.blast_radius_m
	if owner_jet and owner_jet.spec:
		for t in owner_jet.spec.passive_traits:
			if missile_spec.is_nuclear:
				base_dmg *= (1.0 + t.nuclear_damage_bonus)
		if owner_jet.ability_active and owner_jet.spec.special_ability.effect_tag == "armor_brace":
			blast_r *= 1.25

	# Apply AoE thermal/kinetic blast + Nuclear EMP
	for node in get_tree().get_nodes_in_group("aircraft"):
		if not (node is FighterController) or node.current_hp <= 0.0:
			continue
		if node == owner_jet and not missile_spec.is_nuclear:
			continue
		var d := global_position.distance_to(node.global_position)
		if d <= blast_r:
			var falloff := clampf(1.0 - (d / blast_r) * 0.65, 0.25, 1.0)
			node.apply_damage(base_dmg * falloff, owner_jet, false)
		if missile_spec.is_nuclear and d <= missile_spec.emp_radius_m and node != owner_jet:
			node.apply_emp(4.5)

	if owner_jet and owner_jet.vfx_audio:
		owner_jet.vfx_audio.play_explosion_vfx(global_position, missile_spec.is_nuclear)
	queue_free()
