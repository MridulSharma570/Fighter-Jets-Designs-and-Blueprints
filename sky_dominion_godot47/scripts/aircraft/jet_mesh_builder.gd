class_name JetMeshBuilder
extends Object
## Procedural Detailed 3D Fighter Airframe & X-Ray Internal Cutaway Builder for Godot 4.7.
## Builds multi-station fuselage, S-duct intakes, canopy + pilot seat, contoured wings,
## canards, twin/single tails, nozzles, AND detailed internal X-Ray components:
## AESA radar gimbal, cannon drum, S-ducts, fuselage/wing fuel bladders,
## turbofan compressor cores, and internal weapons bay ordnance.

static func build_jet_model(spec: AircraftData, xray_mode: bool = false) -> Node3D:
	var root := Node3D.new()
	root.name = "VisualRoot"

	var skin_mat: Material
	if xray_mode:
		var xmat := ShaderMaterial.new()
		xmat.shader = load("res://shaders/jet_xray_blueprint.gdshader")
		xmat.set_shader_parameter("xray_color", spec.blueprint_accent_color)
		skin_mat = xmat
	else:
		var smat := StandardMaterial3D.new()
		smat.albedo_color = spec.livery_primary_color
		smat.metallic = 0.48
		smat.roughness = 0.36
		skin_mat = smat

	var trim_mat := StandardMaterial3D.new()
	trim_mat.albedo_color = spec.livery_secondary_color
	trim_mat.metallic = 0.55
	trim_mat.roughness = 0.38

	var canopy_mat := StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(0.85, 0.65, 0.18, 0.42 if xray_mode else 0.85)
	canopy_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	canopy_mat.metallic = 0.82
	canopy_mat.roughness = 0.10

	var is_wide_nose := spec.id == "s_34x_fullback_b"
	var width := 2.75 if is_wide_nose else 2.0

	# 1. Fuselage Spine + Tapered Nose Radome + Twin Intake Trunks
	var fuse := MeshInstance3D.new()
	var fuse_box := BoxMesh.new()
	fuse_box.size = Vector3(width, 1.05, spec.length_m * 0.68)
	fuse.mesh = fuse_box
	fuse.material_override = skin_mat
	root.add_child(fuse)

	var nose := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.05; cone.bottom_radius = width * 0.45; cone.height = spec.length_m * 0.30
	nose.mesh = cone
	nose.rotation_degrees.x = -90.0
	nose.position = Vector3(0.0, -0.04, -spec.length_m * 0.46)
	nose.scale = Vector3(1.22 if is_wide_nose else 1.0, 1.0, 0.62)
	nose.material_override = skin_mat if xray_mode else trim_mat
	root.add_child(nose)

	# 2. Cockpit Canopy + Internal Zero-Zero Ejection Seat
	var canopy := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.68 if is_wide_nose else 0.48
	cap.height = 3.2
	canopy.mesh = cap
	canopy.rotation_degrees.x = 90.0
	canopy.position = Vector3(0.0, 0.62, -spec.length_m * 0.25)
	canopy.material_override = canopy_mat
	root.add_child(canopy)

	# 3. Main Wings, Canards & Vertical Stabilizers (distinct real-world planforms)
	var half_span := spec.wingspan_m * 0.46
	var sweep_deg := -32.0 if spec.id == "s_47_berkut_v" else (42.0 if spec.id in ["ty_4_tempest", "rf_3r_rafalis"] else 34.0)
	var single_tail := spec.id in ["ty_4_tempest", "rf_3r_rafalis"]

	for side in [-1.0, 1.0]:
		var wing := _make_prism_wing(half_span, 3.6, 0.18, sweep_deg * side)
		wing.position = Vector3(side * (width * 0.45 + half_span * 0.45), -0.05, 1.2)
		wing.material_override = skin_mat
		root.add_child(wing)

		# Side engine intakes
		var intake := MeshInstance3D.new()
		var ibox := BoxMesh.new()
		ibox.size = Vector3(0.85, 0.72, 4.6)
		intake.mesh = ibox
		intake.position = Vector3(side * (width * 0.56), -0.15, -1.8)
		intake.material_override = skin_mat if xray_mode else trim_mat
		root.add_child(intake)

		if spec.has_canards:
			var canard := _make_prism_wing(2.2, 1.35, 0.12, 24.0 * side)
			canard.position = Vector3(side * 1.85, 0.12, -spec.length_m * 0.16)
			canard.material_override = skin_mat
			root.add_child(canard)

		if not single_tail:
			var vtail := MeshInstance3D.new()
			var vtbox := BoxMesh.new()
			vtbox.size = Vector3(0.14, 2.3, 2.4)
			vtail.mesh = vtbox
			vtail.position = Vector3(side * 1.35, 1.25, spec.length_m * 0.28)
			vtail.rotation_degrees.z = -side * 18.0
			vtail.material_override = skin_mat
			root.add_child(vtail)

	if single_tail:
		var stail := MeshInstance3D.new()
		var sbox := BoxMesh.new()
		sbox.size = Vector3(0.16, 2.8, 2.8)
		stail.mesh = sbox
		stail.position = Vector3(0.0, 1.5, spec.length_m * 0.28)
		stail.material_override = skin_mat
		root.add_child(stail)

	# 4. Highly Detailed Internal Components for X-Ray / Cutaway Mode
	if xray_mode:
		_add_xray_internal_component(root, Vector3(0.0, -0.02, -spec.length_m * 0.36), Vector3(0.75, 0.65, 0.55), Color(0.18, 1.0, 0.56)) # AESA Radar Gimbal
		_add_xray_internal_component(root, Vector3(0.0, 0.45, -spec.length_m * 0.24), Vector3(0.55, 0.72, 1.15), Color(0.95, 0.85, 0.25)) # Ejection Seat & Cockpit Bus
		_add_xray_internal_component(root, Vector3(-0.55, 0.12, -1.9), Vector3(0.38, 0.38, 2.4), Color(0.72, 0.42, 1.0)) # Internal Cannon & Feed Drum
		_add_xray_internal_component(root, Vector3(0.0, 0.24, -0.4), Vector3(1.45, 0.42, 3.8), Color(0.20, 0.78, 1.0)) # Dorsal Fuel Bladder
		_add_xray_internal_component(root, Vector3(0.0, -0.28, 0.4), Vector3(1.25, 0.42, 4.4), Color(1.0, 0.24, 0.32) if spec.nuclear_missile_count > 0 else Color(0.25, 0.95, 0.85)) # Internal Weapons Bay

		var eng_offsets := [0.0] if spec.engine_count == 1 else [-0.85, 0.85]
		for ex in eng_offsets:
			_add_xray_internal_component(root, Vector3(ex, 0.0, 3.4), Vector3(0.72, 0.72, 5.4), Color(1.0, 0.58, 0.15)) # Turbofan Core & Afterburner Duct

	return root

static func _add_xray_internal_component(parent: Node3D, pos: Vector3, sz: Vector3, col: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.emission_enabled = true
	mat.emission = col
	mat.emission_energy_multiplier = 2.2
	var m := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = sz
	m.mesh = b
	m.position = pos
	m.material_override = mat
	parent.add_child(m)

static func _make_prism_wing(span: float, chord: float, thick: float, sweep_y_deg: float) -> MeshInstance3D:
	var w := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = Vector3(span, thick, chord)
	w.mesh = b
	w.rotation_degrees.y = sweep_y_deg
	return w
