class_name JetMeshBuilder
extends Object
## Procedural High-Detail 3D Fighter Airframe, Full-Body Metalstorm Skinning, Landing Gear, Mounted Ordnance & X-Ray Cutaway Builder for Godot 4.7.

static func build_jet_model(spec: AircraftData, xray_mode: bool = false, skin_override: SkinCatalog.JetSkinSpec = null) -> Node3D:
	var root := Node3D.new()
	root.name = "VisualRoot"

	var skin := skin_override if skin_override != null else SkinCatalog.get_active_jet_skin(spec)
	var skin_mat: Material
	var trim_mat: Material
	var accent_mat: Material
	var radome_mat: Material

	if xray_mode:
		var xmat := ShaderMaterial.new()
		xmat.shader = load("res://shaders/jet_xray_blueprint.gdshader")
		xmat.set_shader_parameter("xray_color", spec.blueprint_accent_color)
		skin_mat = xmat; trim_mat = xmat; accent_mat = xmat; radome_mat = xmat
	else:
		skin_mat = SkinCatalog.create_jet_shader_material(skin)
		trim_mat = _mat(skin.tertiary_color, skin.metallic * 0.85, clampf(skin.roughness + 0.05, 0.1, 0.9))
		accent_mat = _mat(skin.accent_color, 0.38, 0.24, skin.emission_strength > 0.1, skin.accent_color, skin.emission_strength * 0.7)
		radome_mat = _mat(skin.radome_color, 0.16, 0.52)

	var canopy_mat := StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(skin.canopy_tint.r, skin.canopy_tint.g, skin.canopy_tint.b, 0.40 if xray_mode else 0.88)
	canopy_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	canopy_mat.metallic = 0.88
	canopy_mat.roughness = 0.08

	var titanium_mat := _mat(Color(0.24, 0.27, 0.32), 0.90, 0.20)
	var chrome_mat := _mat(Color(0.84, 0.88, 0.92), 0.95, 0.12)
	var dark_mat := _mat(Color(0.03, 0.035, 0.045), 0.08, 0.92)
	var tire_mat := _mat(Color(0.08, 0.085, 0.10), 0.04, 0.90)
	var hud_mat := _mat(Color(0.18, 0.95, 0.82), 0.2, 0.1, true, Color(0.18, 0.95, 0.82), 2.2)

	var L := spec.length_m * 0.50
	var S := spec.wingspan_m * 0.54
	var is_wide := spec.id == "s_34x_fullback_b"
	var is_fsw := spec.id == "s_47_berkut_v"
	var is_delta := spec.id in ["ty_4_tempest", "rf_3r_rafalis"]
	var is_flat_nozzle := spec.id == "f_22v_talon"
	var is_stealth := spec.id in ["s_57_felonis", "j_20x_wyvern", "f_22v_talon", "f_35k_thunder", "kf_21m_borama"]
	var W := 1.65 if is_wide else (1.40 if spec.id == "s_57_felonis" else 1.22)
	var chine := 0.88 if is_stealth else 0.22
	var nose_drop := -0.18 if spec.id in ["s_35x_flanker_z", "s_34x_fullback_b"] else -0.06
	var nose_w := 1.50 if is_wide else (0.84 if is_delta else 0.96)

	# 1. Dielectric Nose Radome + Sculpted Full-Body Skin Fuselage + Pitot Probe
	_add_loft(root, [
		[-L*1.06, 0.0, nose_drop, 0.02, 0.02],
		[-L*0.92, 0.0, nose_drop*0.75, nose_w*0.36, 0.23],
		[-L*0.74, 0.0, -0.01, nose_w*0.68, 0.39]
	], 24, radome_mat, chine)

	_add_loft(root, [
		[-L*0.74, 0.0, -0.01, nose_w*0.68, 0.39],
		[-L*0.50, 0.0, 0.04, W*1.04, 0.51],
		[-L*0.18, 0.0, 0.07, W*1.32, 0.54],
		[ L*0.16, 0.0, 0.06, W*1.38, 0.52],
		[ L*0.52, 0.0, 0.04, W*1.18, 0.45],
		[ L*0.84, 0.0, 0.01, W*0.90, 0.34]
	], 24, skin_mat, chine)

	if not (spec.id in ["f_22v_talon", "f_35k_thunder", "j_20x_wyvern"]):
		_add_loft(root, [[-L*1.16, 0.0, nose_drop, 0.006, 0.006], [-L*1.05, 0.0, nose_drop, 0.026, 0.026]], 8, chrome_mat, 0.0)

	if spec.id == "rf_3r_rafalis":
		_add_loft(root, [[-L*0.76, 0.42, 0.24, 0.018, 0.018], [-L*0.58, 0.36, 0.18, 0.036, 0.036]], 8, chrome_mat, 0.0)

	# 2. Cockpit Tub, Ejection Seat(s), HUD Combiner & Custom Tinted Bubble Canopy
	var seat_xs := [-0.26, 0.26] if is_wide else [0.0]
	for sx in seat_xs:
		_add_loft(root, [[-L*0.47, sx, 0.44, 0.13, 0.14], [-L*0.40, sx, 0.50, 0.14, 0.16]], 10, dark_mat, 0.4)
		_add_fin(root, Vector3(sx, 0.42, -L*0.56), Vector3(sx, 0.42, -L*0.53), Vector3(sx, 0.54, -L*0.54), Vector3(sx, 0.54, -L*0.51), 0.07, hud_mat)

	var can_w := 0.76 if is_wide else 0.45
	_add_loft(root, [
		[-L*0.66, 0.0, 0.30, 0.06, 0.04],
		[-L*0.54, 0.0, 0.50, can_w, 0.34],
		[-L*0.42, 0.0, 0.62, can_w*1.06, 0.42],
		[-L*0.28, 0.0, 0.54, can_w*0.92, 0.34],
		[-L*0.16, 0.0, 0.36, can_w*0.55, 0.16]
	], 20, canopy_mat, 0.0)
	_add_loft(root, [[-L*0.57, 0.0, 0.48, can_w*1.02, 0.35], [-L*0.54, 0.0, 0.52, can_w*1.04, 0.37]], 16, titanium_mat, 0.0)

	# 3. Distinct Intakes, Engine Nacelles, Compressor Fans & Nozzles
	if spec.id == "ty_4_tempest":
		_add_loft(root, [[-L*0.54, 0.0, -0.34, 0.74, 0.24], [-L*0.24, 0.0, -0.28, 0.80, 0.26], [L*0.16, 0.0, -0.20, 0.76, 0.26]], 14, trim_mat, 0.75)

	var eng_xs := [0.0] if spec.engine_count == 1 else ([-0.92, 0.92] if spec.id == "s_57_felonis" else [-0.80, 0.80])
	for ex in eng_xs:
		_add_loft(root, [
			[-L*0.38, ex, -0.14, 0.46, 0.28],
			[-L*0.10, ex, -0.05, 0.54, 0.38],
			[ L*0.32, ex,  0.04, 0.55, 0.41],
			[ L*0.88, ex,  0.00, 0.50 if is_flat_nozzle else 0.42, 0.22 if is_flat_nozzle else 0.42]
		], 18, skin_mat, 0.45)
		_add_loft(root, [[-L*0.39, ex, -0.14, 0.35, 0.19], [-L*0.24, ex, -0.12, 0.31, 0.17]], 12, dark_mat, 0.5)
		_add_loft(root, [[-L*0.27, ex, -0.12, 0.22, 0.14], [-L*0.25, ex, -0.12, 0.04, 0.04]], 10, chrome_mat, 0.0)
		_add_loft(root, [
			[L*0.88, ex, 0.0, 0.50 if is_flat_nozzle else 0.42, 0.22 if is_flat_nozzle else 0.42],
			[L*1.05, ex, 0.0, 0.44 if is_flat_nozzle else 0.33, 0.16 if is_flat_nozzle else 0.33]
		], 18, titanium_mat, 0.82 if is_flat_nozzle else 0.0)

	# 4. Contoured Full-Skin Wings, LERX, Canards, Tails & Colored Squadron Trim
	var tip_z := -1.45 if is_fsw else (3.85 if is_delta else 2.65)
	var root_z := -0.95 if is_delta else -1.65
	var trail_z := 1.25 if is_fsw else (4.85 if is_delta else 4.45)
	var single_tail := is_delta

	for s in [-1.0, 1.0]:
		_add_airfoil(root, Vector3(s*W*0.68, 0.06, -L*0.64), Vector3(s*W*0.95, 0.05, root_z+0.5), Vector3(s*W*1.38, 0.05, root_z), Vector3(s*W*1.12, 0.04, root_z+1.6), 0.14, 0.10, skin_mat)
		_add_airfoil(root, Vector3(s*W*1.05, 0.05, root_z), Vector3(s*W*1.05, 0.04, trail_z), Vector3(s*S, 0.01, tip_z), Vector3(s*S, 0.01, tip_z+1.15), 0.20, 0.06, skin_mat)
		_add_airfoil(root, Vector3(s*S*0.86, 0.02, tip_z+(root_z-tip_z)*0.14), Vector3(s*S*0.86, 0.02, tip_z+1.15+(trail_z-tip_z-1.15)*0.14), Vector3(s*S, 0.015, tip_z), Vector3(s*S, 0.015, tip_z+1.15), 0.09, 0.065, accent_mat)

		if spec.has_canards:
			_add_airfoil(root, Vector3(s*W*0.88, 0.15, -L*0.46), Vector3(s*W*0.88, 0.15, -L*0.18), Vector3(s*(W*0.88+1.82), 0.19, -L*0.24), Vector3(s*(W*0.88+1.72), 0.19, -L*0.09), 0.09, 0.03, skin_mat)
			_add_airfoil(root, Vector3(s*(W*0.88+1.45), 0.18, -L*0.28), Vector3(s*(W*0.88+1.45), 0.18, -L*0.12), Vector3(s*(W*0.88+1.82), 0.19, -L*0.24), Vector3(s*(W*0.88+1.72), 0.19, -L*0.09), 0.05, 0.03, accent_mat)

		if not single_tail:
			_add_airfoil(root, Vector3(s*W*0.78, 0.02, L*0.54), Vector3(s*W*0.78, 0.02, L*0.94), Vector3(s*(W*0.78+2.40), 0.01, L*0.84), Vector3(s*(W*0.78+2.08), 0.01, L*1.06), 0.10, 0.03, skin_mat)
			var cant := 0.68 if is_stealth else 0.18
			_add_fin(root, Vector3(s*0.96, 0.30, L*0.36), Vector3(s*0.96, 0.30, L*0.94), Vector3(s*(0.96+cant), 2.28, L*0.70), Vector3(s*(0.96+cant), 2.28, L*1.00), 0.065, skin_mat)
			_add_fin(root, Vector3(s*(0.96+cant*0.62), 1.60, L*0.58), Vector3(s*(0.96+cant*0.62), 1.60, L*0.96), Vector3(s*(0.96+cant*0.84), 2.02, L*0.66), Vector3(s*(0.96+cant*0.84), 2.02, L*0.98), 0.070, accent_mat)

	if single_tail:
		_add_fin(root, Vector3(0.0, 0.34, L*0.26), Vector3(0.0, 0.34, L*0.96), Vector3(0.0, 2.55, L*0.74), Vector3(0.0, 2.55, L*1.02), 0.075, skin_mat)
		_add_fin(root, Vector3(0.0, 1.80, L*0.58), Vector3(0.0, 1.80, L*0.98), Vector3(0.0, 2.22, L*0.66), Vector3(0.0, 2.22, L*1.00), 0.080, accent_mat)

	# 5. Tricycle Landing Gear + Colored Bay Doors
	if not xray_mode:
		_add_loft(root, [[-L*0.64, 0.0, -0.34, 0.045, 0.045], [-L*0.62, 0.0, -1.32, 0.045, 0.045]], 8, chrome_mat, 0.0)
		_add_gear_wheel(root, Vector3(-0.12, -1.40, -L*0.62), 0.22, 0.075, tire_mat, chrome_mat)
		_add_gear_wheel(root, Vector3( 0.12, -1.40, -L*0.62), 0.22, 0.075, tire_mat, chrome_mat)
		_add_fin(root, Vector3(0.24, -0.34, -L*0.72), Vector3(0.24, -0.34, -L*0.46), Vector3(0.30, -0.88, -L*0.72), Vector3(0.30, -0.88, -L*0.46), 0.018, trim_mat)
		for s in [-1.0, 1.0]:
			var gx := s * (W * 0.92 + 0.35)
			var gz := L * 0.14
			_add_loft(root, [[gz, gx*0.82, -0.26, 0.06, 0.06], [gz, gx, -1.26, 0.055, 0.055]], 8, chrome_mat, 0.0)
			_add_gear_wheel(root, Vector3(gx + s*0.12, -1.34, gz), 0.30, 0.11, tire_mat, chrome_mat)
			_add_fin(root, Vector3(gx+s*0.26, -0.26, gz-0.46), Vector3(gx+s*0.26, -0.26, gz+0.42), Vector3(gx+s*0.36, -0.96, gz-0.46), Vector3(gx+s*0.36, -0.96, gz+0.42), 0.02, trim_mat)

		# 6. Mounted Colored Ordnance (Missiles, Rocket Pods, Nuclear Warheads & Internal Cannon)
		var db := Engine.get_main_loop().root.get_node_or_null("GameDatabase")
		if db:
			for s in [-1.0, 1.0]:
				var tip_id := spec.secondary_missile_id if spec.secondary_missile_id != "" else spec.primary_missile_id
				var m_spec = db.get_missile(tip_id)
				if m_spec:
					var m_vis := OrdnanceMeshBuilder.build_missile_visual(m_spec)
					m_vis.position = Vector3(s * S, -0.10, tip_z + 0.25)
					m_vis.scale = Vector3.ONE * 0.65
					root.add_child(m_vis)
				if spec.can_equip_rockets and spec.rocket_id != "":
					var r_spec = db.get_rocket(spec.rocket_id)
					if r_spec:
						var pod := OrdnanceMeshBuilder.build_rocket_pod_visual(r_spec)
						pod.position = Vector3(s * (W * 1.05 + 2.15), -0.32, 1.65)
						root.add_child(pod)
			if spec.nuclear_missile_id != "":
				var n_spec = db.get_missile(spec.nuclear_missile_id)
				if n_spec:
					var n_vis := OrdnanceMeshBuilder.build_missile_visual(n_spec)
					n_vis.position = Vector3(0.0, -0.44, 0.2)
					n_vis.scale = Vector3.ONE * 0.65
					root.add_child(n_vis)

	# 7. Detailed Internal Components for X-Ray / Cutaway Mode
	if xray_mode:
		_add_xray_internal_component(root, Vector3(0.0, -0.02, -L*0.76), Vector3(0.75, 0.65, 0.55), Color(0.18, 1.0, 0.56))
		_add_xray_internal_component(root, Vector3(0.0, 0.42, -L*0.46), Vector3(0.55, 0.72, 1.15), Color(0.95, 0.85, 0.25))
		_add_xray_internal_component(root, Vector3(-0.55, 0.12, -1.9), Vector3(0.38, 0.38, 2.4), Color(0.72, 0.42, 1.0))
		_add_xray_internal_component(root, Vector3(0.0, 0.24, -0.4), Vector3(1.45, 0.42, 3.8), Color(0.20, 0.78, 1.0))
		_add_xray_internal_component(root, Vector3(0.0, -0.28, 0.4), Vector3(1.25, 0.42, 4.4), Color(1.0, 0.24, 0.32) if spec.nuclear_missile_count > 0 else Color(0.25, 0.95, 0.85))
		for ex in eng_xs:
			_add_xray_internal_component(root, Vector3(ex, 0.0, 3.4), Vector3(0.72, 0.72, 5.4), Color(1.0, 0.58, 0.15))

	return root

static func _mat(col: Color, metal: float, rough: float, em: bool = false, em_col: Color = Color.BLACK, em_e: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col; m.metallic = metal; m.roughness = rough
	if em:
		m.emission_enabled = true; m.emission = em_col; m.emission_energy_multiplier = em_e
	return m

static func _add_gear_wheel(parent: Node3D, pos: Vector3, rad: float, w: float, t_mat: Material, h_mat: Material) -> void:
	var tire := MeshInstance3D.new()
	var tm := CylinderMesh.new(); tm.top_radius = rad; tm.bottom_radius = rad; tm.height = w * 2.0
	tire.mesh = tm; tire.rotation_degrees.z = 90.0; tire.position = pos; tire.material_override = t_mat
	parent.add_child(tire)
	var hub := MeshInstance3D.new()
	var hm := CylinderMesh.new(); hm.top_radius = rad * 0.52; hm.bottom_radius = rad * 0.52; hm.height = w * 2.08
	hub.mesh = hm; hub.rotation_degrees.z = 90.0; hub.position = pos; hub.material_override = h_mat
	parent.add_child(hub)

static func _add_loft(parent: Node3D, stations: Array, segs: int, mat: Material, chine: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var verts: Array[Vector3] = []
	for r in stations.size():
		var s: Array = stations[r]
		var z := float(s[0]); var cx := float(s[1]); var cy := float(s[2]); var rx := float(s[3]); var ry := float(s[4])
		for i in segs + 1:
			var a := (float(i) / float(segs)) * TAU
			var ca := cos(a); var sa := sin(a)
			if chine > 0.0:
				ca = signf(ca) * pow(absf(ca), 1.0 - chine * 0.42)
				sa = signf(sa) * pow(absf(sa), 1.0 + chine * 0.28)
			verts.append(Vector3(cx + ca * rx, cy + sa * ry, z))
	var stride := segs + 1
	for r in stations.size() - 1:
		for i in segs:
			var a := r * stride + i; var b := a + 1; var c := (r + 1) * stride + i; var d := c + 1
			st.add_vertex(verts[a]); st.add_vertex(verts[c]); st.add_vertex(verts[b])
			st.add_vertex(verts[b]); st.add_vertex(verts[c]); st.add_vertex(verts[d])
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit(); mi.material_override = mat
	parent.add_child(mi)

static func _add_airfoil(parent: Node3D, r_le: Vector3, r_te: Vector3, t_le: Vector3, t_te: Vector3, th_r: float, th_t: float, mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ch := [0.0, 0.22, 0.62, 1.0]
	var pf := [0.0, 1.0, 0.55, 0.0]
	for c in ch.size() - 1:
		var p00 := r_le.lerp(r_te, ch[c]); var p10 := r_le.lerp(r_te, ch[c+1])
		var p01 := t_le.lerp(t_te, ch[c]); var p11 := t_le.lerp(t_te, ch[c+1])
		var u00 := p00 + Vector3(0, th_r*pf[c], 0); var u10 := p10 + Vector3(0, th_r*pf[c+1], 0)
		var u01 := p01 + Vector3(0, th_t*pf[c], 0); var u11 := p11 + Vector3(0, th_t*pf[c+1], 0)
		st.add_vertex(u00); st.add_vertex(u01); st.add_vertex(u11)
		st.add_vertex(u00); st.add_vertex(u11); st.add_vertex(u10)
		var l00 := p00 - Vector3(0, th_r*pf[c]*0.4, 0); var l10 := p10 - Vector3(0, th_r*pf[c+1]*0.4, 0)
		var l01 := p01 - Vector3(0, th_t*pf[c]*0.4, 0); var l11 := p11 - Vector3(0, th_t*pf[c+1]*0.4, 0)
		st.add_vertex(l00); st.add_vertex(l11); st.add_vertex(l01)
		st.add_vertex(l00); st.add_vertex(l10); st.add_vertex(l11)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit(); mi.material_override = mat
	parent.add_child(mi)

static func _add_fin(parent: Node3D, r_le: Vector3, r_te: Vector3, t_le: Vector3, t_te: Vector3, thick: float, mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rm := r_le.lerp(r_te, 0.35); var tm := t_le.lerp(t_te, 0.35)
	for side in [-1.0, 1.0]:
		var rmo := rm + Vector3(side * thick, 0, 0); var tmo := tm + Vector3(side * thick * 0.55, 0, 0)
		st.add_vertex(r_le); st.add_vertex(t_le); st.add_vertex(tmo)
		st.add_vertex(r_le); st.add_vertex(tmo); st.add_vertex(rmo)
		st.add_vertex(rmo); st.add_vertex(tmo); st.add_vertex(t_te)
		st.add_vertex(rmo); st.add_vertex(t_te); st.add_vertex(r_te)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit(); mi.material_override = mat
	parent.add_child(mi)

static func _add_xray_internal_component(parent: Node3D, pos: Vector3, sz: Vector3, col: Color) -> void:
	var mat := _mat(col, 0.2, 0.2, true, col, 2.2)
	var m := MeshInstance3D.new()
	var b := BoxMesh.new(); b.size = sz
	m.mesh = b; m.position = pos; m.material_override = mat
	parent.add_child(m)
