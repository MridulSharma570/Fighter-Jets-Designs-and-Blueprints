class_name OrdnanceMeshBuilder
extends RefCounted
## Full-Body Multi-Color 3D Mesh & Metalstorm Skin Builder for Every Missile, Nuclear Warhead, Rocket/Pod, and Cannon in Godot 4.7.

static func _palette_for_missile(id: String) -> Dictionary:
	match id:
		"am_120d": return {"body": Color(0.86, 0.89, 0.93), "nose": Color(0.28, 0.33, 0.40), "band": Color(0.92, 0.70, 0.08), "fin": Color(0.22, 0.27, 0.34)}
		"am_9x":   return {"body": Color(0.89, 0.91, 0.94), "nose": Color(0.85, 0.47, 0.05), "band": Color(0.92, 0.70, 0.08), "fin": Color(0.14, 0.17, 0.22)}
		"mt_200":  return {"body": Color(0.80, 0.84, 0.88), "nose": Color(0.20, 0.25, 0.32), "band": Color(0.06, 0.65, 0.91), "fin": Color(0.10, 0.14, 0.20)}
		"ir_t":    return {"body": Color(0.85, 0.89, 0.92), "nose": Color(0.96, 0.62, 0.05), "band": Color(0.04, 0.72, 0.83), "fin": Color(0.12, 0.16, 0.22)}
		"as_132":  return {"body": Color(0.84, 0.81, 0.76), "nose": Color(0.71, 0.33, 0.04), "band": Color(0.86, 0.15, 0.15), "fin": Color(0.14, 0.17, 0.23)}
		"mk_em":   return {"body": Color(0.72, 0.77, 0.83), "nose": Color(0.20, 0.25, 0.33), "band": Color(0.15, 0.39, 0.92), "fin": Color(0.10, 0.14, 0.20)}
		"mk_ir":   return {"body": Color(0.76, 0.80, 0.85), "nose": Color(0.06, 0.65, 0.91), "band": Color(0.96, 0.62, 0.05), "fin": Color(0.14, 0.17, 0.23)}
		"pl_15x":  return {"body": Color(0.93, 0.95, 0.97), "nose": Color(0.23, 0.26, 0.30), "band": Color(0.15, 0.39, 0.92), "fin": Color(0.28, 0.33, 0.40)}
		"pl_10x":  return {"body": Color(0.88, 0.90, 0.93), "nose": Color(0.92, 0.68, 0.12), "band": Color(0.15, 0.55, 0.88), "fin": Color(0.20, 0.24, 0.30)}
		"r_77v":   return {"body": Color(0.89, 0.91, 0.94), "nose": Color(0.28, 0.33, 0.40), "band": Color(0.86, 0.15, 0.15), "fin": Color(0.62, 0.68, 0.75)}
		"r_77s":   return {"body": Color(0.78, 0.82, 0.87), "nose": Color(0.20, 0.25, 0.33), "band": Color(0.92, 0.35, 0.05), "fin": Color(0.78, 0.83, 0.89)}
		"r_74x":   return {"body": Color(0.87, 0.90, 0.93), "nose": Color(0.96, 0.62, 0.05), "band": Color(0.86, 0.15, 0.15), "fin": Color(0.14, 0.17, 0.23)}
		"r_73v":   return {"body": Color(0.54, 0.59, 0.52), "nose": Color(0.92, 0.35, 0.05), "band": Color(0.92, 0.70, 0.08), "fin": Color(0.14, 0.17, 0.22)}
		"r_27v":   return {"body": Color(0.84, 0.86, 0.88), "nose": Color(0.22, 0.26, 0.32), "band": Color(0.88, 0.22, 0.15), "fin": Color(0.28, 0.32, 0.36)}
		"r_37x":   return {"body": Color(0.74, 0.78, 0.83), "nose": Color(0.18, 0.20, 0.24), "band": Color(0.95, 0.45, 0.10), "fin": Color(0.18, 0.22, 0.28)}
		"kh_102x_nuke": return {"body": Color(0.14, 0.16, 0.21), "nose": Color(0.08, 0.09, 0.12), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.22, 0.27, 0.33)}
		"cj_20x_nuke":  return {"body": Color(0.22, 0.28, 0.36), "nose": Color(0.12, 0.16, 0.23), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.39, 0.45, 0.54)}
		"b61n_nuke":    return {"body": Color(0.76, 0.80, 0.86), "nose": Color(0.39, 0.45, 0.54), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.58, 0.64, 0.72)}
		"storm_n_nuke": return {"body": Color(0.18, 0.22, 0.27), "nose": Color(0.09, 0.11, 0.14), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.28, 0.33, 0.41)}
		"kh_59n_nuke":  return {"body": Color(0.29, 0.36, 0.44), "nose": Color(0.06, 0.65, 0.91), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.20, 0.25, 0.33)}
		"asmp_r_nuke":  return {"body": Color(0.90, 0.92, 0.95), "nose": Color(0.16, 0.20, 0.24), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.28, 0.33, 0.41)}
		"kh_102s_nuke": return {"body": Color(0.11, 0.14, 0.18), "nose": Color(0.06, 0.08, 0.10), "band": Color(0.94, 0.22, 0.22), "fin": Color(0.20, 0.25, 0.33)}
		_: return {"body": Color(0.85, 0.88, 0.92), "nose": Color(0.28, 0.32, 0.38), "band": Color(0.92, 0.70, 0.12), "fin": Color(0.22, 0.26, 0.32)}

static func _palette_for_rocket(id: String) -> Dictionary:
	match id:
		"s8_kom":    return {"pod": Color(0.24, 0.31, 0.25), "body": Color(0.84, 0.87, 0.90), "head": Color(0.88, 0.20, 0.16), "band": Color(0.85, 0.47, 0.05)}
		"s13_heavy": return {"pod": Color(0.18, 0.21, 0.25), "body": Color(0.32, 0.36, 0.40), "head": Color(0.96, 0.62, 0.05), "band": Color(0.86, 0.15, 0.15)}
		"s24_heavy": return {"pod": Color(0.22, 0.26, 0.24), "body": Color(0.45, 0.50, 0.44), "head": Color(0.86, 0.15, 0.15), "band": Color(0.95, 0.72, 0.12)}
		"log_70":    return {"pod": Color(0.29, 0.34, 0.40), "body": Color(0.80, 0.84, 0.88), "head": Color(0.06, 0.65, 0.91), "band": Color(0.22, 0.74, 0.97)}
		"cr_70":     return {"pod": Color(0.84, 0.88, 0.92), "body": Color(0.90, 0.92, 0.95), "head": Color(0.92, 0.70, 0.08), "band": Color(0.86, 0.15, 0.15)}
		"sn_68":     return {"pod": Color(0.34, 0.42, 0.49), "body": Color(0.82, 0.86, 0.90), "head": Color(0.94, 0.27, 0.27), "band": Color(0.15, 0.39, 0.92)}
		_: return {"pod": Color(0.35, 0.40, 0.45), "body": Color(0.84, 0.86, 0.88), "head": Color(0.88, 0.25, 0.16), "band": Color(0.95, 0.75, 0.15)}

static func _palette_for_cannon(id: String) -> Dictionary:
	match id:
		"gsh_30v":        return {"body": Color(0.20, 0.25, 0.33), "nose": Color(0.58, 0.64, 0.72), "band": Color(0.98, 0.45, 0.09), "fin": Color(0.06, 0.09, 0.16)}
		"cs_23v_pod":     return {"body": Color(0.12, 0.16, 0.22), "nose": Color(0.39, 0.45, 0.55), "band": Color(0.06, 0.72, 0.51), "fin": Color(0.06, 0.09, 0.16)}
		"m61v_vulcanix":  return {"body": Color(0.24, 0.29, 0.24), "nose": Color(0.69, 0.73, 0.77), "band": Color(0.92, 0.70, 0.03), "fin": Color(0.12, 0.16, 0.23)}
		"m61k_precision": return {"body": Color(0.29, 0.38, 0.47), "nose": Color(0.80, 0.84, 0.88), "band": Color(0.22, 0.74, 0.97), "fin": Color(0.06, 0.09, 0.16)}
		"gau_22x":        return {"body": Color(0.18, 0.20, 0.24), "nose": Color(0.61, 0.64, 0.69), "band": Color(0.96, 0.62, 0.04), "fin": Color(0.07, 0.09, 0.15)}
		"bk_27x":         return {"body": Color(0.34, 0.32, 0.30), "nose": Color(0.66, 0.64, 0.62), "band": Color(0.94, 0.27, 0.27), "fin": Color(0.11, 0.10, 0.09)}
		"g30m_791x":      return {"body": Color(0.25, 0.31, 0.39), "nose": Color(0.80, 0.84, 0.88), "band": Color(0.96, 0.62, 0.04), "fin": Color(0.06, 0.09, 0.16)}
		_: return {"body": Color(0.24, 0.28, 0.34), "nose": Color(0.68, 0.72, 0.78), "band": Color(0.94, 0.65, 0.12), "fin": Color(0.10, 0.12, 0.18)}

static func build_missile_visual(spec: WeaponData.MissileSpec, skin_override: SkinCatalog.WeaponSkinSpec = null) -> Node3D:
	var root := Node3D.new()
	root.name = "Visual_" + spec.id
	var id := spec.id
	var pal := _palette_for_missile(id)
	var wskin := skin_override if skin_override != null else SkinCatalog.get_active_weapon_skin(id, pal)

	var is_nuke := spec.is_nuclear
	var is_stealth_cruise := id in ["kh_102x_nuke", "storm_n_nuke", "kh_102s_nuke"]
	var is_ramjet := id in ["mt_200", "asmp_r_nuke"]
	var is_turbofan_cruise := id in ["cj_20x_nuke", "kh_59n_nuke"]
	var is_ir := spec.guidance == WeaponData.GuidanceType.INFRARED
	var is_lattice := id in ["r_77v", "r_77s"]
	var is_b61 := id == "b61n_nuke"

	var body_len := 4.4 if is_nuke else (3.6 if id in ["mt_200", "pl_15x", "r_37x"] else 2.8)
	var body_rad := 0.24 if is_nuke else 0.095

	var mat_body: Material = SkinCatalog.create_weapon_shader_material(wskin)
	var mat_nose := _make_mat(wskin.nose_color, 0.25 if is_ir else 0.20, 0.06 if is_ir else 0.40, is_ir, wskin.nose_color, 0.38)
	var mat_band := _make_mat(wskin.band_color, 0.28, 0.30, is_nuke or wskin.emission_strength > 0.1, wskin.band_color, 0.70)
	var mat_amber := _make_mat(Color(0.96, 0.70, 0.12), 0.55, 0.28, is_nuke, Color(1.0, 0.68, 0.10), 0.35)
	var mat_fin := _make_mat(wskin.fin_color, 0.75, 0.26)
	var mat_chrome := _make_mat(Color(0.86, 0.90, 0.94), 0.94, 0.12)
	var mat_dark := _make_mat(Color(0.04, 0.05, 0.07), 0.12, 0.88)

	if is_stealth_cruise:
		var box := BoxMesh.new()
		box.size = Vector3(body_rad * 2.1, body_rad * 1.45, body_len * 0.78)
		var b_inst := MeshInstance3D.new()
		b_inst.mesh = box; b_inst.material_override = mat_body
		root.add_child(b_inst)
	else:
		var cyl := CylinderMesh.new()
		cyl.top_radius = body_rad; cyl.bottom_radius = body_rad * (0.76 if id == "r_77s" else 1.0)
		cyl.height = body_len * 0.74
		var b_inst := MeshInstance3D.new()
		b_inst.mesh = cyl; b_inst.rotation_degrees.x = 90.0; b_inst.material_override = mat_body
		root.add_child(b_inst)

	var raceway := BoxMesh.new()
	raceway.size = Vector3(body_rad * 0.32, body_rad * 0.24, body_len * 0.56)
	var rw_inst := MeshInstance3D.new()
	rw_inst.mesh = raceway; rw_inst.position = Vector3(0.0, body_rad * 0.92, body_len * 0.04)
	rw_inst.material_override = mat_fin
	root.add_child(rw_inst)

	if is_ir:
		var dome := SphereMesh.new()
		dome.radius = body_rad * 0.96; dome.height = body_rad * 1.92
		var n_inst := MeshInstance3D.new()
		n_inst.mesh = dome; n_inst.position.z = -body_len * 0.37; n_inst.material_override = mat_nose
		root.add_child(n_inst)

		var eye := SphereMesh.new()
		eye.radius = body_rad * 0.45; eye.height = body_rad * 0.90
		var e_inst := MeshInstance3D.new()
		e_inst.mesh = eye; e_inst.position.z = -body_len * 0.39; e_inst.material_override = mat_chrome
		root.add_child(e_inst)
	else:
		var cone := CylinderMesh.new()
		cone.top_radius = 0.01; cone.bottom_radius = body_rad
		cone.height = body_len * 0.24
		var n_inst := MeshInstance3D.new()
		n_inst.mesh = cone; n_inst.rotation_degrees.x = -90.0
		n_inst.position.z = -body_len * 0.48; n_inst.material_override = mat_nose
		root.add_child(n_inst)

	var band := CylinderMesh.new()
	band.top_radius = body_rad * 1.04; band.bottom_radius = body_rad * 1.04
	band.height = body_len * (0.11 if is_nuke else 0.07)
	var band_inst := MeshInstance3D.new()
	band_inst.mesh = band; band_inst.rotation_degrees.x = 90.0
	band_inst.position.z = -body_len * 0.18; band_inst.material_override = mat_band
	root.add_child(band_inst)

	if is_nuke:
		var band2 := CylinderMesh.new()
		band2.top_radius = body_rad * 1.04; band2.bottom_radius = body_rad * 1.04
		band2.height = body_len * 0.06
		var b2_inst := MeshInstance3D.new()
		b2_inst.mesh = band2; b2_inst.rotation_degrees.x = 90.0
		b2_inst.position.z = -body_len * 0.07; b2_inst.material_override = mat_amber
		root.add_child(b2_inst)

	if is_ramjet:
		for s in [-1.0, 1.0]:
			var intake := BoxMesh.new()
			intake.size = Vector3(body_rad * 0.66, body_rad * 0.66, body_len * 0.46)
			var i_inst := MeshInstance3D.new()
			i_inst.mesh = intake; i_inst.position = Vector3(s * body_rad * 1.08, 0.0, body_len * 0.08)
			i_inst.material_override = mat_fin
			root.add_child(i_inst)

			var throat := BoxMesh.new()
			throat.size = Vector3(body_rad * 0.44, body_rad * 0.44, 0.08)
			var t_inst := MeshInstance3D.new()
			t_inst.mesh = throat; t_inst.position = Vector3(s * body_rad * 1.08, 0.0, -body_len * 0.15)
			t_inst.material_override = mat_dark
			root.add_child(t_inst)

			var shock := CylinderMesh.new()
			shock.top_radius = 0.008; shock.bottom_radius = body_rad * 0.22; shock.height = body_rad * 0.55
			var sc_inst := MeshInstance3D.new()
			sc_inst.mesh = shock; sc_inst.rotation_degrees.x = -90.0
			sc_inst.position = Vector3(s * body_rad * 1.08, 0.0, -body_len * 0.17)
			sc_inst.material_override = mat_chrome
			root.add_child(sc_inst)
	elif is_turbofan_cruise:
		var pod := CylinderMesh.new()
		pod.top_radius = body_rad * 0.55; pod.bottom_radius = body_rad * 0.48; pod.height = body_len * 0.28
		var p_inst := MeshInstance3D.new()
		p_inst.mesh = pod; p_inst.rotation_degrees.x = 90.0
		p_inst.position = Vector3(0.0, -body_rad * 1.05, body_len * 0.16)
		p_inst.material_override = mat_fin
		root.add_child(p_inst)

		var fan := CylinderMesh.new()
		fan.top_radius = body_rad * 0.40; fan.bottom_radius = body_rad * 0.40; fan.height = 0.06
		var f_inst := MeshInstance3D.new()
		f_inst.mesh = fan; f_inst.rotation_degrees.x = 90.0
		f_inst.position = Vector3(0.0, -body_rad * 1.05, body_len * 0.02)
		f_inst.material_override = mat_dark
		root.add_child(f_inst)

	if is_nuke and not is_b61:
		for s in [-1.0, 1.0]:
			var wing := BoxMesh.new()
			wing.size = Vector3(body_len * 0.36, 0.03, body_rad * 1.4)
			var w_inst := MeshInstance3D.new()
			w_inst.mesh = wing; w_inst.position = Vector3(s * body_len * 0.19, 0.0, -body_len * 0.04)
			w_inst.rotation_degrees.y = -s * 24.0; w_inst.material_override = mat_body
			root.add_child(w_inst)

	if id in ["r_74x", "r_73v", "pl_10x", "am_9x"]:
		for i in 4:
			var ang := (PI * 0.25) + i * (PI * 0.5)
			var can := BoxMesh.new()
			can.size = Vector3(0.018, body_rad * 1.85, body_len * 0.08)
			var c_inst := MeshInstance3D.new()
			c_inst.mesh = can
			c_inst.position = Vector3(cos(ang) * body_rad * 1.35, sin(ang) * body_rad * 1.35, -body_len * 0.25)
			c_inst.rotation.z = ang - PI * 0.5
			c_inst.material_override = mat_fin
			root.add_child(c_inst)

	for i in 4:
		var ang := (PI * 0.25) + i * (PI * 0.5)
		if is_lattice:
			var frame := Node3D.new()
			frame.position = Vector3(cos(ang) * body_rad * 1.55, sin(ang) * body_rad * 1.55, body_len * 0.30)
			frame.rotation.z = ang - PI * 0.5
			for bar_x in [-0.055, 0.0, 0.055]:
				var vbar := BoxMesh.new(); vbar.size = Vector3(0.012, body_rad * 2.2, 0.03)
				var vb := MeshInstance3D.new(); vb.mesh = vbar; vb.position.x = bar_x; vb.material_override = mat_chrome
				frame.add_child(vb)
			for bar_y in [-body_rad * 0.95, 0.0, body_rad * 0.95]:
				var hbar := BoxMesh.new(); hbar.size = Vector3(0.125, 0.012, 0.03)
				var hb := MeshInstance3D.new(); hb.mesh = hbar; hb.position.y = bar_y; hb.material_override = mat_chrome
				frame.add_child(hb)
			root.add_child(frame)
		else:
			var fin := BoxMesh.new()
			fin.size = Vector3(0.025, body_rad * (2.6 if is_nuke else 2.4), body_len * 0.16)
			var f_inst := MeshInstance3D.new()
			f_inst.mesh = fin
			f_inst.position = Vector3(cos(ang) * body_rad * 1.55, sin(ang) * body_rad * 1.55, body_len * 0.30)
			f_inst.rotation.z = ang - PI * 0.5
			f_inst.material_override = mat_fin
			root.add_child(f_inst)

	return root

static func build_rocket_visual(spec: WeaponData.RocketSpec, skin_override: SkinCatalog.WeaponSkinSpec = null) -> Node3D:
	var root := Node3D.new()
	root.name = "Visual_" + spec.id
	var pal := _palette_for_rocket(spec.id)
	var wskin := skin_override if skin_override != null else SkinCatalog.get_active_weapon_skin(spec.id, {"body": pal["body"], "nose": pal["head"], "band": pal["band"], "fin": Color(0.22, 0.25, 0.30)})
	var cal_scale := clampf(float(spec.caliber_mm) / 80.0, 0.85, 2.1)
	var rad := 0.045 * cal_scale
	var length := 1.15 * cal_scale

	var mat_body: Material = SkinCatalog.create_weapon_shader_material(wskin)
	var mat_head := _make_mat(wskin.nose_color, 0.32, 0.32, true, spec.plume_color, 0.85)
	var mat_band := _make_mat(wskin.band_color, 0.35, 0.30)
	var mat_fin := _make_mat(wskin.fin_color, 0.75, 0.28)

	var body := CylinderMesh.new()
	body.top_radius = rad; body.bottom_radius = rad; body.height = length * 0.76
	var b_inst := MeshInstance3D.new()
	b_inst.mesh = body; b_inst.rotation_degrees.x = 90.0; b_inst.material_override = mat_body
	root.add_child(b_inst)

	var band := CylinderMesh.new()
	band.top_radius = rad * 1.04; band.bottom_radius = rad * 1.04; band.height = length * 0.10
	var bd_inst := MeshInstance3D.new()
	bd_inst.mesh = band; bd_inst.rotation_degrees.x = 90.0; bd_inst.position.z = -length * 0.26; bd_inst.material_override = mat_band
	root.add_child(bd_inst)

	var head := CylinderMesh.new()
	head.top_radius = 0.008; head.bottom_radius = rad; head.height = length * 0.26
	var h_inst := MeshInstance3D.new()
	h_inst.mesh = head; h_inst.rotation_degrees.x = -90.0
	h_inst.position.z = -length * 0.50; h_inst.material_override = mat_head
	root.add_child(h_inst)

	for i in 4:
		var ang := (PI * 0.25) + i * (PI * 0.5)
		var fin := BoxMesh.new()
		fin.size = Vector3(0.012, rad * 2.2, length * 0.16)
		var f_inst := MeshInstance3D.new()
		f_inst.mesh = fin
		f_inst.position = Vector3(cos(ang) * rad * 1.35, sin(ang) * rad * 1.35, length * 0.32)
		f_inst.rotation.z = ang - PI * 0.5
		f_inst.material_override = mat_fin
		root.add_child(f_inst)

	return root

static func build_rocket_pod_visual(spec: WeaponData.RocketSpec, skin_override: SkinCatalog.WeaponSkinSpec = null) -> Node3D:
	var root := Node3D.new()
	root.name = "Pod_" + spec.id
	var pal := _palette_for_rocket(spec.id)
	var wskin := skin_override if skin_override != null else SkinCatalog.get_active_weapon_skin(spec.id, {"body": pal["pod"], "nose": pal["head"], "band": pal["band"], "fin": Color(0.32, 0.36, 0.42)})
	var rad := 0.24 if spec.id == "s13_heavy" else 0.20
	var mat_pod: Material = SkinCatalog.create_weapon_shader_material(wskin)
	var mat_band := _make_mat(wskin.band_color, 0.35, 0.30)
	var mat_dark := _make_mat(Color(0.04, 0.05, 0.07), 0.10, 0.90)
	var mat_tip := _make_mat(wskin.nose_color, 0.35, 0.30)
	var mat_brace := _make_mat(wskin.fin_color, 0.80, 0.25)

	var hull := CylinderMesh.new()
	hull.top_radius = rad; hull.bottom_radius = rad; hull.height = 2.15
	var h_inst := MeshInstance3D.new()
	h_inst.mesh = hull; h_inst.rotation_degrees.x = 90.0; h_inst.material_override = mat_pod
	root.add_child(h_inst)

	var collar := CylinderMesh.new()
	collar.top_radius = rad * 1.03; collar.bottom_radius = rad * 1.03; collar.height = 0.22
	var c_inst := MeshInstance3D.new()
	c_inst.mesh = collar; c_inst.rotation_degrees.x = 90.0; c_inst.position.z = -0.82; c_inst.material_override = mat_band
	root.add_child(c_inst)

	var face := CylinderMesh.new()
	face.top_radius = rad * 0.88; face.bottom_radius = rad * 0.88; face.height = 0.06
	var f_inst := MeshInstance3D.new()
	f_inst.mesh = face; f_inst.rotation_degrees.x = 90.0; f_inst.position.z = -1.06
	f_inst.material_override = mat_dark
	root.add_child(f_inst)

	for i in 6:
		var ang := i * (PI / 3.0)
		var tip := CylinderMesh.new()
		tip.top_radius = 0.006; tip.bottom_radius = 0.028; tip.height = 0.12
		var t_inst := MeshInstance3D.new()
		t_inst.mesh = tip; t_inst.rotation_degrees.x = -90.0
		t_inst.position = Vector3(cos(ang) * rad * 0.52, sin(ang) * rad * 0.52, -1.12)
		t_inst.material_override = mat_tip
		root.add_child(t_inst)

	for bz in [-0.45, 0.45]:
		var brace := BoxMesh.new(); brace.size = Vector3(0.06, 0.09, 0.14)
		var br := MeshInstance3D.new(); br.mesh = brace
		br.position = Vector3(0.0, rad + 0.03, bz); br.material_override = mat_brace
		root.add_child(br)

	return root

static func build_cannon_visual(spec: WeaponData.CannonSpec, skin_override: SkinCatalog.WeaponSkinSpec = null) -> Node3D:
	var root := Node3D.new()
	root.name = "Cannon_" + spec.id
	var pal := _palette_for_cannon(spec.id)
	var wskin := skin_override if skin_override != null else SkinCatalog.get_active_weapon_skin(spec.id, pal)

	var mat_body: Material = SkinCatalog.create_weapon_shader_material(wskin)
	var mat_barrel := _make_mat(wskin.nose_color, 0.88, 0.18)
	var mat_band := _make_mat(wskin.band_color, 0.45, 0.25)
	var mat_mount := _make_mat(wskin.fin_color, 0.72, 0.30)

	# Receiver Housing
	var rec := BoxMesh.new(); rec.size = Vector3(0.42, 0.36, 1.35)
	var r_inst := MeshInstance3D.new(); r_inst.mesh = rec; r_inst.position.z = 0.68; r_inst.material_override = mat_body
	root.add_child(r_inst)

	# Ammo Drum + Calibration Band
	var drum := CylinderMesh.new(); drum.top_radius = 0.34; drum.bottom_radius = 0.34; drum.height = 0.72
	var d_inst := MeshInstance3D.new(); d_inst.mesh = drum; d_inst.rotation_degrees.x = 90.0
	d_inst.position = Vector3(0.42, 0.0, 0.88); d_inst.material_override = mat_body
	root.add_child(d_inst)

	var dband := CylinderMesh.new(); dband.top_radius = 0.35; dband.bottom_radius = 0.35; dband.height = 0.12
	var db_inst := MeshInstance3D.new(); db_inst.mesh = dband; db_inst.rotation_degrees.x = 90.0
	db_inst.position = Vector3(0.42, 0.0, 0.88); db_inst.material_override = mat_band
	root.add_child(db_inst)

	# Recoil Cradle / Mount
	var mount := BoxMesh.new(); mount.size = Vector3(0.24, 0.14, 0.85)
	var m_inst := MeshInstance3D.new(); m_inst.mesh = mount; m_inst.position = Vector3(0.0, -0.22, 0.55); m_inst.material_override = mat_mount
	root.add_child(m_inst)

	# Barrels (1, 4, or 6 rotary) + Muzzle Clamp Collar
	var bc := 6 if spec.id in ["m61v_vulcanix", "m61k_precision"] else (4 if spec.id in ["cs_23v_pod", "gau_22x"] else 1)
	for i in bc:
		var ang := 0.0 if bc == 1 else (float(i) / float(bc)) * TAU
		var bx := 0.0 if bc == 1 else cos(ang) * 0.11
		var by := 0.0 if bc == 1 else sin(ang) * 0.11
		var bar := CylinderMesh.new(); bar.top_radius = 0.032; bar.bottom_radius = 0.036; bar.height = 1.65
		var b_inst := MeshInstance3D.new(); b_inst.mesh = bar; b_inst.rotation_degrees.x = 90.0
		b_inst.position = Vector3(bx, by, -0.82); b_inst.material_override = mat_barrel
		root.add_child(b_inst)

	var clamp_m := CylinderMesh.new(); clamp_m.top_radius = 0.16; clamp_m.bottom_radius = 0.16; clamp_m.height = 0.14
	var c_inst := MeshInstance3D.new(); c_inst.mesh = clamp_m; c_inst.rotation_degrees.x = 90.0
	c_inst.position.z = -1.42; c_inst.material_override = mat_band
	root.add_child(c_inst)

	return root

static func _make_mat(albedo: Color, metallic: float, roughness: float,
		emissive: bool = false, em_col: Color = Color.BLACK, em_energy: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo; m.metallic = metallic; m.roughness = roughness
	if em:
		m.emission_enabled = true; m.emission = em_col; m.emission_energy_multiplier = em_energy
	return m
