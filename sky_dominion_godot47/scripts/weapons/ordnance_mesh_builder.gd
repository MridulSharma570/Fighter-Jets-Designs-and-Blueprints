class_name OrdnanceMeshBuilder
extends RefCounted
## Bespoke 3D Mesh & PBR Material Builder for Every Missile, Nuclear Warhead, and Rocket/Pod in Godot 4.7.

static func build_missile_visual(spec: WeaponData.MissileSpec) -> Node3D:
	var root := Node3D.new()
	root.name = "Visual_" + spec.id
	var id := spec.id

	var is_nuke := spec.is_nuclear
	var is_stealth_cruise := id in ["kh_102x_nuke", "storm_n_nuke", "kh_102s_nuke"]
	var is_ramjet := id in ["mt_200", "asmp_r_nuke"]
	var is_turbofan_cruise := id in ["cj_20x_nuke", "kh_59n_nuke"]
	var is_ir := spec.guidance == WeaponData.GuidanceType.INFRARED
	var is_lattice := id in ["r_77v", "r_77s"]
	var is_b61 := id == "b61n_nuke"

	var body_len := 4.4 if is_nuke else (3.6 if id in ["mt_200", "pl_15x", "r_37x"] else 2.8)
	var body_rad := 0.24 if is_nuke else 0.095

	var mat_body := _make_mat(
		Color(0.16, 0.19, 0.23) if is_stealth_cruise else (Color(0.76, 0.80, 0.84) if is_b61 else Color(0.88, 0.90, 0.94)),
		0.72 if is_b61 else 0.28, 0.28 if is_b61 else 0.35
	)
	var mat_nose := _make_mat(
		Color(0.95, 0.62, 0.18) if is_ir else Color(0.24, 0.27, 0.32),
		0.20 if is_ir else 0.15, 0.08 if is_ir else 0.45,
		is_ir, Color(0.95, 0.55, 0.12), 0.35
	)
	var mat_band := _make_mat(
		Color(0.92, 0.14, 0.16) if is_nuke else Color(0.95, 0.78, 0.16),
		0.25, 0.32, is_nuke, Color(1.0, 0.22, 0.12), 0.65
	)
	var mat_fin := _make_mat(Color(0.22, 0.25, 0.30), 0.75, 0.26)

	# 1. Fuselage / Airframe Body
	if is_stealth_cruise:
		var box := BoxMesh.new()
		box.size = Vector3(body_rad * 2.1, body_rad * 1.45, body_len * 0.78)
		var b_inst := MeshInstance3D.new()
		b_inst.mesh = box; b_inst.material_override = mat_body
		root.add_child(b_inst)
	else:
		var cyl := CylinderMesh.new()
		cyl.top_radius = body_rad; cyl.bottom_radius = body_rad * (0.78 if id == "r_77s" else 1.0)
		cyl.height = body_len * 0.74
		var b_inst := MeshInstance3D.new()
		b_inst.mesh = cyl; b_inst.rotation_degrees.x = 90.0; b_inst.material_override = mat_body
		root.add_child(b_inst)

	# 2. Seeker Nose / Radome
	if is_ir:
		var dome := SphereMesh.new()
		dome.radius = body_rad * 0.96; dome.height = body_rad * 1.92
		var n_inst := MeshInstance3D.new()
		n_inst.mesh = dome; n_inst.position.z = -body_len * 0.37; n_inst.material_override = mat_nose
		root.add_child(n_inst)
	else:
		var cone := CylinderMesh.new()
		cone.top_radius = 0.01; cone.bottom_radius = body_rad
		cone.height = body_len * 0.24
		var n_inst := MeshInstance3D.new()
		n_inst.mesh = cone; n_inst.rotation_degrees.x = -90.0
		n_inst.position.z = -body_len * 0.48; n_inst.material_override = mat_nose
		root.add_child(n_inst)

	# 3. Warhead / Nuclear Hazard Band
	var band := CylinderMesh.new()
	band.top_radius = body_rad * 1.04; band.bottom_radius = body_rad * 1.04
	band.height = body_len * (0.11 if is_nuke else 0.07)
	var band_inst := MeshInstance3D.new()
	band_inst.mesh = band; band_inst.rotation_degrees.x = 90.0
	band_inst.position.z = -body_len * 0.18; band_inst.material_override = mat_band
	root.add_child(band_inst)

	# 4. Ramjet Cheek Intakes or Ventral Turbofan Pod
	if is_ramjet:
		for s in [-1.0, 1.0]:
			var intake := BoxMesh.new()
			intake.size = Vector3(body_rad * 0.65, body_rad * 0.65, body_len * 0.46)
			var i_inst := MeshInstance3D.new()
			i_inst.mesh = intake; i_inst.position = Vector3(s * body_rad * 1.08, 0.0, body_len * 0.08)
			i_inst.material_override = mat_fin
			root.add_child(i_inst)
	elif is_turbofan_cruise:
		var pod := CylinderMesh.new()
		pod.top_radius = body_rad * 0.55; pod.bottom_radius = body_rad * 0.48; pod.height = body_len * 0.28
		var p_inst := MeshInstance3D.new()
		p_inst.mesh = pod; p_inst.rotation_degrees.x = 90.0
		p_inst.position = Vector3(0.0, -body_rad * 1.05, body_len * 0.16)
		p_inst.material_override = mat_fin
		root.add_child(p_inst)

	# 5. Wings & Tail Fins (Cruise Swept Wings, Lattice Grid Fins, or Cruciform Delta Fins)
	if is_nuke and not is_b61:
		for s in [-1.0, 1.0]:
			var wing := BoxMesh.new()
			wing.size = Vector3(body_len * 0.34, 0.03, body_rad * 1.4)
			var w_inst := MeshInstance3D.new()
			w_inst.mesh = wing; w_inst.position = Vector3(s * body_len * 0.19, 0.0, -body_len * 0.04)
			w_inst.rotation_degrees.y = -s * 24.0; w_inst.material_override = mat_body
			root.add_child(w_inst)

	for i in 4:
		var ang := (PI * 0.25) + i * (PI * 0.5)
		var fin := BoxMesh.new()
		fin.size = Vector3(0.025 if not is_lattice else 0.08, body_rad * (2.6 if is_nuke else 2.4), body_len * (0.11 if is_lattice else 0.16))
		var f_inst := MeshInstance3D.new()
		f_inst.mesh = fin
		f_inst.position = Vector3(cos(ang) * body_rad * 1.55, sin(ang) * body_rad * 1.55, body_len * 0.30)
		f_inst.rotation.z = ang - PI * 0.5
		f_inst.material_override = mat_fin
		root.add_child(f_inst)

	return root

static func build_rocket_visual(spec: WeaponData.RocketSpec) -> Node3D:
	var root := Node3D.new()
	root.name = "Visual_" + spec.id
	var cal_scale := clampf(float(spec.caliber_mm) / 80.0, 0.85, 2.1)
	var rad := 0.045 * cal_scale
	var length := 1.15 * cal_scale

	var mat_body := _make_mat(
		Color(0.24, 0.28, 0.30) if spec.id == "s13_heavy" else Color(0.84, 0.86, 0.88),
		0.40, 0.35
	)
	var mat_head := _make_mat(
		Color(0.20, 0.72, 0.85) if spec.guidance == WeaponData.RocketGuidance.LASER_SEMI_GUIDED else Color(0.88, 0.25, 0.16),
		0.30, 0.35, true, spec.plume_color, 0.8
	)

	var body := CylinderMesh.new()
	body.top_radius = rad; body.bottom_radius = rad; body.height = length * 0.76
	var b_inst := MeshInstance3D.new()
	b_inst.mesh = body; b_inst.rotation_degrees.x = 90.0; b_inst.material_override = mat_body
	root.add_child(b_inst)

	var head := CylinderMesh.new()
	head.top_radius = 0.008; head.bottom_radius = rad; head.height = length * 0.26
	var h_inst := MeshInstance3D.new()
	h_inst.mesh = head; h_inst.rotation_degrees.x = -90.0
	h_inst.position.z = -length * 0.50; h_inst.material_override = mat_head
	root.add_child(h_inst)

	return root

static func build_rocket_pod_visual(spec: WeaponData.RocketSpec) -> Node3D:
	var root := Node3D.new()
	root.name = "Pod_" + spec.id
	var rad := 0.24 if spec.id == "s13_heavy" else 0.20
	var mat_pod := _make_mat(
		Color(0.22, 0.26, 0.24) if spec.id in ["s8_kom", "s13_heavy"] else Color(0.66, 0.70, 0.75),
		0.45, 0.38
	)
	var mat_dark := _make_mat(Color(0.04, 0.05, 0.07), 0.10, 0.90)

	var hull := CylinderMesh.new()
	hull.top_radius = rad; hull.bottom_radius = rad; hull.height = 2.15
	var h_inst := MeshInstance3D.new()
	h_inst.mesh = hull; h_inst.rotation_degrees.x = 90.0; h_inst.material_override = mat_pod
	root.add_child(h_inst)

	var face := CylinderMesh.new()
	face.top_radius = rad * 0.88; face.bottom_radius = rad * 0.88; face.height = 0.06
	var f_inst := MeshInstance3D.new()
	f_inst.mesh = face; f_inst.rotation_degrees.x = 90.0; f_inst.position.z = -1.06
	f_inst.material_override = mat_dark
	root.add_child(f_inst)

	return root

static func _make_mat(albedo: Color, metallic: float, roughness: float,
		emissive: bool = false, em_col: Color = Color.BLACK, em_energy: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo; m.metallic = metallic; m.roughness = roughness
	if emissive:
		m.emission_enabled = true; m.emission = em_col; m.emission_energy_multiplier = em_energy
	return m
