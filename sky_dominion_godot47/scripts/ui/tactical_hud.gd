class_name TacticalHUD
extends Control
## Collimated Military Glass-Cockpit HUD for Godot 4.7.
## Draws crisp vector Pitch Ladder, Airspeed/Altitude tapes, Target Lock diamond,
## Lead-Pip Cannon Sight, RWR Threat Ring, Nuclear Alert Banner, Weapon Bay Status,
## Flare Counter, and Airframe Trait / Overdrive Ability Telemetry.

@export var player_jet: FighterController
@export var camera_3d: Camera3D

var _ammo_snapshot: Dictionary = {}
var _target: Node3D = null
var _lock_progress: float = 0.0
var _is_locked: bool = false
var _active_slot: String = "primary"
var _incoming_count: int = 0
var _nuclear_alert: bool = false
var _ability_active: bool = false
var _ability_rem: float = 0.0
var _ability_cd: float = 0.0
var _pulse_time: float = 0.0

func bind_fighter(jet: FighterController, cam: Camera3D) -> void:
	player_jet = jet
	camera_3d = cam
	if jet.weapon_system:
		jet.weapon_system.ammo_changed.connect(func(s: Dictionary) -> void: _ammo_snapshot = s)
		jet.weapon_system.lock_progress_changed.connect(func(t: Node3D, p: float, locked: bool, slot: String) -> void:
			_target = t; _lock_progress = p; _is_locked = locked; _active_slot = slot
		)
		jet.weapon_system.rwr_warning.connect(func(inc: Array[Node3D], nuke: bool) -> void:
			_incoming_count = inc.size(); _nuclear_alert = nuke
		)
	jet.ability_state_changed.connect(func(act: bool, rem: float, cd: float) -> void:
		_ability_active = act; _ability_rem = rem; _ability_cd = cd
	)

func _process(delta: float) -> void:
	_pulse_time += delta
	queue_redraw()

func _draw() -> void:
	if player_jet == null or player_jet.spec == null:
		return

	var sz := size
	var center := sz * 0.5
	var hud_col := Color(0.18, 1.0, 0.56, 0.92)
	if player_jet.emp_timer > 0.0:
		hud_col = Color(1.0, 0.25, 0.25, 0.75 if int(_pulse_time * 18.0) % 2 == 0 else 0.25)

	var font := ThemeDB.fallback_font
	var spec := player_jet.spec

	# 1. Center Boresight Cross & Artificial Horizon Pitch Ladder
	draw_line(center + Vector2(-18, 0), center + Vector2(-6, 0), hud_col, 2.0)
	draw_line(center + Vector2(6, 0), center + Vector2(18, 0), hud_col, 2.0)
	draw_line(center + Vector2(0, -14), center + Vector2(0, -5), hud_col, 2.0)

	var roll_rad := player_jet.rotation.z
	var pitch_deg := rad_to_deg(player_jet.rotation.x)
	for step in [-20, -10, 0, 10, 20]:
		var dy := (step - pitch_deg) * 5.0
		if absf(dy) > 190.0:
			continue
		var p_off := Vector2(0, -dy).rotated(-roll_rad)
		var dir_x := Vector2(1, 0).rotated(-roll_rad)
		var bar_w := 90.0 if step == 0 else 48.0
		draw_line(center + p_off - dir_x * bar_w, center + p_off - dir_x * 18.0, hud_col, 1.5)
		draw_line(center + p_off + dir_x * 18.0, center + p_off + dir_x * bar_w, hud_col, 1.5)

	# 2. Airspeed & Altitude Tapes
	var knots := int(player_jet.current_speed * 1.94384)
	var mach := player_jet.current_speed / 340.3
	var alt_m := int(maxf(0.0, player_jet.global_position.y))

	draw_rect(Rect2(center.x - 320, center.y - 36, 108, 72), Color(0.02, 0.08, 0.06, 0.55), true)
	draw_rect(Rect2(center.x - 320, center.y - 36, 108, 72), hud_col, false, 1.5)
	draw_string(font, Vector2(center.x - 310, center.y - 8), "SPD %d KT" % knots, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, hud_col)
	draw_string(font, Vector2(center.x - 310, center.y + 18), "M %.2f  G %.1f" % [mach, player_jet.g_force], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hud_col)

	draw_rect(Rect2(center.x + 212, center.y - 36, 114, 72), Color(0.02, 0.08, 0.06, 0.55), true)
	draw_rect(Rect2(center.x + 212, center.y - 36, 114, 72), hud_col, false, 1.5)
	draw_string(font, Vector2(center.x + 220, center.y - 8), "ALT %d M" % alt_m, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, hud_col)
	draw_string(font, Vector2(center.x + 220, center.y + 18), "FUEL %d%%" % int(player_jet.fuel), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hud_col)

	# 3. Top Aircraft Identity & Level Badge
	var header := "%s  [LV.%d | ABILITY LV.%d]  HP %d/%d" % [
		spec.callsign_name, player_jet.jet_level, player_jet.ability_level,
		int(player_jet.current_hp), int(player_jet.max_hp)
	]
	draw_string(font, Vector2(28, 36), header, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, spec.blueprint_accent_color)

	# 4. Target Lock-On Diamond & Lead-Pip Sight
	if _target != null and is_instance_valid(_target) and camera_3d != null:
		if not camera_3d.is_position_behind(_target.global_position):
			var screen_pos := camera_3d.unproject_position(_target.global_position)
			var lock_col := Color(1.0, 0.22, 0.22) if _is_locked else Color(1.0, 0.85, 0.22)
			var box_r := 26.0 - 8.0 * _lock_progress
			draw_rect(Rect2(screen_pos - Vector2(box_r, box_r), Vector2(box_r * 2.0, box_r * 2.0)), lock_col, false, 2.2)
			var dist_km := player_jet.global_position.distance_to(_target.global_position) / 1000.0
			draw_string(font, screen_pos + Vector2(box_r + 6, 4), "%.1f KM %s" % [dist_km, "LOCK" if _is_locked else "ACQ"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, lock_col)

	# 5. Bottom-Left Weapon Bays, Flares & Nuclear Status
	var y0 := sz.y - 135.0
	draw_rect(Rect2(24, y0, 360, 112), Color(0.02, 0.05, 0.08, 0.72), true)
	draw_rect(Rect2(24, y0, 360, 112), hud_col, false, 1.5)
	draw_string(font, Vector2(36, y0 + 24), "CANNON: %d  | HEAT %d%%" % [_ammo_snapshot.get("cannon", 0), int(_ammo_snapshot.get("cannon_heat", 0.0) * 100.0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, hud_col)
	draw_string(font, Vector2(36, y0 + 48), "MSL [1]: PRI %d | SEC %d | ACTIVE: %s" % [_ammo_snapshot.get("primary", 0), _ammo_snapshot.get("secondary", 0), _active_slot.to_upper()], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, hud_col)
	draw_string(font, Vector2(36, y0 + 72), "NUCLEAR [N]: %d | ROCKETS [R]: %d" % [_ammo_snapshot.get("nuclear", 0), _ammo_snapshot.get("rockets", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.78, 0.25))
	draw_string(font, Vector2(36, y0 + 96), "FLARES [F]: %d / %d" % [_ammo_snapshot.get("flares", 0), spec.flare_spec.capacity if spec.flare_spec else 0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.55, 0.95, 1.0))

	# 6. Bottom-Right Airframe Overdrive Ability & Traits
	var ab := spec.special_ability
	if ab != null:
		var x_r := sz.x - 384.0
		draw_rect(Rect2(x_r, y0, 360, 112), Color(0.02, 0.05, 0.08, 0.72), true)
		draw_rect(Rect2(x_r, y0, 360, 112), spec.blueprint_accent_color, false, 1.5)
		var status := "ACTIVE %.1fs" % _ability_rem if _ability_active else ("COOLDOWN %.1fs" % _ability_cd if _ability_cd > 0.0 else "READY [X]")
		draw_string(font, Vector2(x_r + 14, y0 + 26), "ABILITY: %s (%s)" % [ab.title, status], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, spec.blueprint_accent_color)
		if spec.passive_traits.size() > 0:
			draw_string(font, Vector2(x_r + 14, y0 + 54), "TRAIT 1: " + spec.passive_traits[0].title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hud_col)
		if spec.passive_traits.size() > 1:
			draw_string(font, Vector2(x_r + 14, y0 + 78), "TRAIT 2: " + spec.passive_traits[1].title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hud_col)

	# 7. RWR Threat & Nuclear Launch Alert
	if _nuclear_alert:
		var blink := int(_pulse_time * 8.0) % 2 == 0
		if blink:
			draw_rect(Rect2(center.x - 210, 62, 420, 40), Color(0.75, 0.05, 0.05, 0.85), true)
			draw_string(font, Vector2(center.x - 185, 89), "!! NUCLEAR LAUNCH DETECTED - EVADE !!", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.95, 0.35))
	elif _incoming_count > 0:
		draw_string(font, Vector2(center.x - 120, 92), "MISSILE WARNING x%d [F FLARE]" % _incoming_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.35, 0.25))
