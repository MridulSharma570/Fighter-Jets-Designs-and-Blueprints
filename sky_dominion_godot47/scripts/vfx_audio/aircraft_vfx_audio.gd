class_name AircraftVfxAudio
extends Node3D
## Physically Modeled Jet Engine & Combat Audio + VFX System for Godot 4.7.
## Uses Voss-McCartney pink/brown noise filtering, bandpass combustor rumble,
## turbofan N1/N2 blade-pass harmonics, supersonic afterburner crackle,
## and realistic cannon/missile/rocket/flare/nuclear acoustic envelopes.

var aircraft_spec: AircraftData
var _engine_player: AudioStreamPlayer3D
var _engine_playback: AudioStreamGeneratorPlayback
var _sfx_player: AudioStreamPlayer3D
var _sfx_playback: AudioStreamGeneratorPlayback

var _afterburner_meshes: Array[MeshInstance3D] = []
var _afterburner_mats: Array[ShaderMaterial] = []
var _contrail_left: GPUParticles3D
var _contrail_right: GPUParticles3D

# Filter & Pink Noise states for realistic jet turbine & afterburner synthesis
var _pink_b0 := 0.0; var _pink_b1 := 0.0; var _pink_b2 := 0.0
var _lp_rumble := 0.0
var _bp_mid := 0.0; var _bp_mid_prev := 0.0
var _phase_n1 := 0.0; var _phase_n2 := 0.0; var _phase_flutter := 0.0
var _sfx_queue: Array[Dictionary] = []
var _sample_rate: float = 22050.0

func _ready() -> void:
	_setup_audio_generators()
	_setup_contrails()

func _setup_audio_generators() -> void:
	_engine_player = AudioStreamPlayer3D.new()
	var eng_gen := AudioStreamGenerator.new()
	eng_gen.mix_rate = _sample_rate
	eng_gen.buffer_length = 0.08
	_engine_player.stream = eng_gen
	_engine_player.max_distance = 2500.0
	_engine_player.volume_db = -8.0
	add_child(_engine_player)
	_engine_player.play()
	_engine_playback = _engine_player.get_stream_playback()

	_sfx_player = AudioStreamPlayer3D.new()
	var sfx_gen := AudioStreamGenerator.new()
	sfx_gen.mix_rate = _sample_rate
	sfx_gen.buffer_length = 0.14
	_sfx_player.stream = sfx_gen
	_sfx_player.max_distance = 4000.0
	sfx_gen.buffer_length = 0.14
	_sfx_player.volume_db = -2.0
	add_child(_sfx_player)
	_sfx_player.play()
	_sfx_playback = _sfx_player.get_stream_playback()

func _setup_contrails() -> void:
	for i in range(2):
		var p := GPUParticles3D.new()
		p.amount = 48
		p.lifetime = 1.4
		p.emitting = false
		var pmat := ParticleProcessMaterial.new()
		pmat.gravity = Vector3.ZERO
		pmat.initial_velocity_min = 0.5
		pmat.initial_velocity_max = 1.5
		pmat.color = Color(0.88, 0.94, 1.0, 0.45)
		p.process_material = pmat
		var q := QuadMesh.new()
		q.size = Vector2(0.35, 0.35)
		p.draw_pass_1 = q
		p.position = Vector3(-5.5 if i == 0 else 5.5, 0.0, 2.5)
		add_child(p)
		if i == 0:
			_contrail_left = p
		else:
			_contrail_right = p

func configure_from_aircraft(spec: AircraftData) -> void:
	aircraft_spec = spec
	_build_afterburner_cones()

func _build_afterburner_cones() -> void:
	for m in _afterburner_meshes:
		if is_instance_valid(m):
			m.queue_free()
	_afterburner_meshes.clear()
	_afterburner_mats.clear()

	var shader := load("res://shaders/afterburner_plume.gdshader") as Shader
	var offsets := [Vector3(0.0, 0.0, 6.2)] if aircraft_spec.engine_count == 1 else [Vector3(-0.95, 0.0, 6.2), Vector3(0.95, 0.0, 6.2)]

	for off in offsets:
		var cone := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.46
		cyl.bottom_radius = 0.05
		cyl.height = 4.6
		cone.mesh = cyl
		cone.rotation_degrees.x = -90.0
		cone.position = off
		if shader:
			var smat := ShaderMaterial.new()
			smat.shader = shader
			smat.set_shader_parameter("core_color", aircraft_spec.afterburner_color_core)
			smat.set_shader_parameter("outer_color", aircraft_spec.afterburner_color_outer)
			smat.set_shader_parameter("intensity", 0.4)
			cone.material_override = smat
			_afterburner_mats.append(smat)
		add_child(cone)
		_afterburner_meshes.append(cone)

func update_flight_telemetry(speed: float, max_speed: float, afterburning: bool, g_force: float, aoa_deg: float) -> void:
	var ratio := clampf(speed / maxf(1.0, max_speed), 0.15, 1.15)
	var ab_boost := 1.45 if afterburning else 0.35

	for smat in _afterburner_mats:
		smat.set_shader_parameter("intensity", clampf(ratio * ab_boost, 0.15, 2.5))
		smat.set_shader_parameter("mach_diamonds", 6.0 if afterburning else 2.0)

	var high_g := g_force > 3.6 or aoa_deg > 11.0
	if _contrail_left and _contrail_right:
		_contrail_left.emitting = high_g
		_contrail_right.emitting = high_g

	_fill_realistic_jet_engine_audio(ratio, afterburning)
	_fill_sfx_audio()

func _next_pink_noise() -> float:
	var white := randf_range(-1.0, 1.0)
	_pink_b0 = 0.99765 * _pink_b0 + white * 0.0990460
	_pink_b1 = 0.96300 * _pink_b1 + white * 0.2965164
	_pink_b2 = 0.57000 * _pink_b2 + white * 1.0526913
	return (_pink_b0 + _pink_b1 + _pink_b2 + white * 0.1848) * 0.22

func _fill_realistic_jet_engine_audio(speed_ratio: float, afterburning: bool) -> void:
	if _engine_playback == null or aircraft_spec == null:
		return
	var frames := _engine_playback.get_frames_available()
	var n1_freq := 1420.0 * aircraft_spec.engine_base_pitch * (0.75 + speed_ratio * 0.55)
	var n2_freq := 2680.0 * aircraft_spec.engine_base_pitch * (0.80 + speed_ratio * 0.40)
	var ab_gain := 1.55 if afterburning else 0.45
	var crackle_rate := 38.0 if afterburning else 12.0

	for i in range(frames):
		var pink := _next_pink_noise()
		# Deep jet exhaust rumble (lowpass ~110 Hz)
		_lp_rumble = _lp_rumble * 0.965 + pink * 0.035
		# Mid-band jet roar / afterburner shear noise (~350-900 Hz)
		var hp := pink - _lp_rumble
		_bp_mid = _bp_mid * 0.84 + hp * 0.16
		var mid_band := _bp_mid - _bp_mid_prev
		_bp_mid_prev = _bp_mid * 0.92

		# Supersonic afterburner flutter modulation
		_phase_flutter = fmod(_phase_flutter + crackle_rate / _sample_rate, 1.0)
		var flutter := 0.78 + 0.22 * sin(_phase_flutter * TAU)

		# Subtle turbofan compressor blade-pass whine (soft harmonics, not harsh synth)
		_phase_n1 = fmod(_phase_n1 + n1_freq / _sample_rate, 1.0)
		_phase_n2 = fmod(_phase_n2 + n2_freq / _sample_rate, 1.0)
		var turbine := (sin(_phase_n1 * TAU) * 0.032 + sin(_phase_n2 * TAU) * 0.015) * (0.6 + speed_ratio * 0.6)

		var jet_roar := (_lp_rumble * 2.8 + mid_band * 1.9 * ab_gain) * flutter + turbine
		var sample := clampf(jet_roar * 0.55, -0.95, 0.95)
		_engine_playback.push_frame(Vector2(sample, sample))

func _fill_sfx_audio() -> void:
	if _sfx_playback == null:
		return
	var frames := _sfx_playback.get_frames_available()
	for i in range(frames):
		var mix := 0.0
		for j in range(_sfx_queue.size() - 1, -1, -1):
			var ev: Dictionary = _sfx_queue[j]
			var t: float = ev["t"]
			var dur: float = ev["dur"]
			if t >= dur:
				_sfx_queue.remove_at(j)
				continue
			var norm := t / dur
			var env := pow(1.0 - norm, float(ev.get("curve", 1.5)))
			var pink := _next_pink_noise()
			var lp: float = ev["lp"]
			lp = lp * (1.0 - float(ev["cutoff"])) + pink * float(ev["cutoff"])
			ev["lp"] = lp
			var sig := lp if bool(ev.get("lowpass_only", false)) else (pink - lp * 0.6)
			var thump := sin(t * float(ev["freq"]) * TAU) * float(ev.get("thump_mix", 0.2)) * exp(-t * 28.0)
			mix += (sig * float(ev.get("noise", 0.8)) + thump) * env * float(ev["gain"])
			ev["t"] = t + (1.0 / _sample_rate)
			ev["freq"] = maxf(24.0, float(ev["freq"]) + float(ev["sweep"]) / _sample_rate)
		mix = clampf(mix, -0.98, 0.98)
		_sfx_playback.push_frame(Vector2(mix, mix))

func play_cannon_shot_sfx(spec: WeaponData.CannonSpec) -> void:
	var freq := 105.0
	var dur := 0.065
	var cutoff := 0.22
	if spec.caliber_mm <= 20.5:
		freq = 135.0; dur = 0.032; cutoff = 0.35
	elif spec.caliber_mm >= 29.0:
		freq = 78.0; dur = 0.095; cutoff = 0.16
	_sfx_queue.append({
		"t": 0.0, "dur": dur, "freq": freq, "sweep": -550.0, "noise": 0.88,
		"thump_mix": 0.42, "cutoff": cutoff, "lp": 0.0, "curve": 2.2, "gain": 0.70
	})

func play_missile_launch_sfx(spec: WeaponData.MissileSpec) -> void:
	var dur := 0.95 if spec.is_nuclear else 0.58
	_sfx_queue.append({
		"t": 0.0, "dur": dur, "freq": 120.0 * spec.launch_sound_pitch,
		"sweep": -180.0, "noise": 0.95, "thump_mix": 0.28, "cutoff": 0.25,
		"lp": 0.0, "curve": 1.3, "gain": 0.85 if spec.is_nuclear else 0.65
	})

func play_rocket_launch_sfx(spec: WeaponData.RocketSpec) -> void:
	_sfx_queue.append({
		"t": 0.0, "dur": 0.18, "freq": 150.0 * spec.sound_pitch,
		"sweep": -320.0, "noise": 0.92, "thump_mix": 0.22, "cutoff": 0.32,
		"lp": 0.0, "curve": 1.6, "gain": 0.50
	})

func play_flare_sfx() -> void:
	# Pyrotechnic mortar pop + high-frequency magnesium sizzle
	_sfx_queue.append({
		"t": 0.0, "dur": 0.24, "freq": 280.0, "sweep": -900.0, "noise": 0.94,
		"thump_mix": 0.35, "cutoff": 0.48, "lp": 0.0, "curve": 1.8, "gain": 0.55
	})

func play_ability_sfx(tag: String) -> void:
	var f := 320.0 if tag in ["ew_jammer", "spectra_ghost"] else 140.0
	_sfx_queue.append({
		"t": 0.0, "dur": 0.55, "freq": f, "sweep": 220.0, "noise": 0.65,
		"thump_mix": 0.35, "cutoff": 0.28, "lp": 0.0, "curve": 1.2, "gain": 0.62
	})

func play_explosion_vfx(world_pos: Vector3, is_nuclear: bool) -> void:
	if is_nuclear:
		_sfx_queue.append({
			"t": 0.0, "dur": 2.40, "freq": 52.0, "sweep": -22.0, "noise": 1.0,
			"thump_mix": 0.55, "cutoff": 0.06, "lp": 0.0, "lowpass_only": true,
			"curve": 1.1, "gain": 1.0
		})
		_spawn_nuclear_blast(world_pos)
	else:
		_sfx_queue.append({
			"t": 0.0, "dur": 0.65, "freq": 85.0, "sweep": -45.0, "noise": 0.96,
			"thump_mix": 0.40, "cutoff": 0.12, "lp": 0.0, "lowpass_only": true,
			"curve": 1.5, "gain": 0.78
		})

func _spawn_nuclear_blast(world_pos: Vector3) -> void:
	var root := Node3D.new()
	get_tree().current_scene.add_child(root)
	root.global_position = world_pos

	var fireball := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 45.0; sph.height = 90.0
	fireball.mesh = sph
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.85, 0.35)
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.65, 0.15)
	fmat.emission_energy_multiplier = 12.0
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fireball.material_override = fmat
	root.add_child(fireball)

	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 40.0; torus.outer_radius = 65.0
	ring.mesh = torus
	var shader := load("res://shaders/nuclear_shockwave.gdshader") as Shader
	if shader:
		var smat := ShaderMaterial.new()
		smat.shader = shader
		ring.material_override = smat
	root.add_child(ring)

	var tween := root.create_tween().set_parallel(true)
	tween.tween_property(fireball, "scale", Vector3.ONE * 18.0, 2.8).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(fmat, "albedo_color:a", 0.0, 4.5)
	tween.tween_property(ring, "scale", Vector3(32.0, 4.0, 32.0), 2.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(root.queue_free)
