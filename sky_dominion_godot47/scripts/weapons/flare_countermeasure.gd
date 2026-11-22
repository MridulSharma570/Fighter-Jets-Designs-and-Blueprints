class_name FlareCountermeasure
extends Node3D
## Incandescent IR/Chaff Flare Pellet ejected by each Fighter Jet.

var owner_jet: FighterController
var velocity_vec: Vector3 = Vector3.ZERO
var life_timer: float = 1.8

func deploy(shooter: FighterController, spec: WeaponData.FlareSpec,
		spawn_pos: Vector3, init_vel: Vector3) -> void:
	owner_jet = shooter
	global_position = spawn_pos
	velocity_vec = init_vel
	life_timer = spec.active_duration_sec

	var orb := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.25; sph.height = 0.5
	orb.mesh = sph
	var mat := StandardMaterial3D.new()
	mat.albedo_color = spec.flare_color
	mat.emission_enabled = true
	mat.emission = spec.flare_color
	mat.emission_energy_multiplier = 6.5
	orb.material_override = mat
	add_child(orb)

func _physics_process(delta: float) -> void:
	velocity_vec.y -= 9.8 * delta
	velocity_vec *= 0.985
	global_position += velocity_vec * delta
	life_timer -= delta
	if life_timer <= 0.0:
		queue_free()
