class_name MainArena
extends Node3D
## Playable Sky Arena Scene Controller for Godot 4.7.
## Keys F1-F10: Hot-swap all 10 Fighter Jets
## Key U: Upgrade active Jet Level (1->20)
## Key V: Toggle 360-deg Color Livery <-> X-Ray Blueprint Mode
## Keys Q/E/A/D/W/S + Shift/Ctrl + LMB/RMB/1/N/R/F/X: Full Combat Controls

@onready var hud: TacticalHUD = $CanvasLayer/TacticalHUD
@onready var cam: Camera3D = $ChaseCamera

var player_jet: FighterController
var active_jet_index: int = 0
var xray_blueprint_mode: bool = false
var orbit_yaw: float = 0.0

func _ready() -> void:
	_spawn_player_jet(GameDatabase.jet_order[0])
	_spawn_enemy_targets()

func _spawn_player_jet(jet_id: String) -> void:
	if is_instance_valid(player_jet):
		player_jet.queue_free()

	player_jet = _create_fighter_node(jet_id, true, 0, Vector3(0, 1200, 0))
	add_child(player_jet)
	hud.bind_fighter(player_jet, cam)

func _spawn_enemy_targets() -> void:
	var enemies := ["j_20x_wyvern", "s_35x_flanker_z", "ty_4_tempest"]
	for i in range(enemies.size()):
		var enemy := _create_fighter_node(enemies[i], false, 1, Vector3((i - 1) * 900.0, 1300.0, -3200.0))
		enemy.rotate_y(PI)
		add_child(enemy)

func _create_fighter_node(jet_id: String, is_plr: bool, team: int, pos: Vector3) -> FighterController:
	var jet := FighterController.new()
	jet.jet_id = jet_id
	jet.is_player = is_plr
	jet.team_id = team
	jet.add_to_group("aircraft")

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(12.0, 3.2, 16.0)
	col.shape = box
	jet.add_child(col)

	var ws := WeaponSystem.new()
	ws.name = "WeaponSystem"
	jet.add_child(ws)

	var vfx := AircraftVfxAudio.new()
	vfx.name = "AircraftVfxAudio"
	jet.add_child(vfx)

	var vis := JetMeshBuilder.build_jet_model(GameDatabase.get_jet(jet_id), xray_blueprint_mode if is_plr else false)
	jet.add_child(vis)

	jet.position = pos
	return jet

func _rebuild_player_visuals() -> void:
	if not is_instance_valid(player_jet):
		return
	var old_vis := player_jet.get_node_or_null("VisualRoot")
	if old_vis:
		old_vis.queue_free()
	var vis := JetMeshBuilder.build_jet_model(player_jet.spec, xray_blueprint_mode)
	player_jet.add_child(vis)

func _process(delta: float) -> void:
	if is_instance_valid(player_jet) and is_instance_valid(cam):
		var offset := Vector3(sin(orbit_yaw) * 26.0, 6.5, cos(orbit_yaw) * 26.0)
		var target_pos := player_jet.global_position + player_jet.global_transform.basis * offset
		cam.global_position = cam.global_position.lerp(target_pos, clampf(10.0 * delta, 0.0, 1.0))
		cam.look_at(player_jet.global_position - player_jet.global_transform.basis.z * (40.0 if absf(orbit_yaw) < 0.05 else 0.0), player_jet.global_transform.basis.y)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_F1 and event.keycode <= KEY_F10:
			var idx := event.keycode - KEY_F1
			if idx < GameDatabase.jet_order.size():
				active_jet_index = idx
				_spawn_player_jet(GameDatabase.jet_order[idx])
		elif event.keycode == KEY_U and is_instance_valid(player_jet):
			UpgradeManager.upgrade_item("jet", player_jet.jet_id)
			player_jet.initialize_jet(player_jet.jet_id)
		elif event.keycode == KEY_V:
			xray_blueprint_mode = not xray_blueprint_mode
			_rebuild_player_visuals()
		elif event.keycode == KEY_BRACKETRIGHT:
			orbit_yaw += 0.35
		elif event.keycode == KEY_BRACKETLEFT:
			orbit_yaw -= 0.35
		elif event.keycode == KEY_BACKSLASH:
			orbit_yaw = 0.0
