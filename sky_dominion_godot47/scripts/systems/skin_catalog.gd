class_name SkinCatalog
extends Object
## Metalstorm-Style Full-Body Customizable Skin & Multi-Color Registry for Fighter Jets, Missiles, Rockets, Cannons & Nuclear Ordnance.

enum PatternType {
	TWO_TONE = 0,
	DIGITAL_PIXEL = 1,
	SPLINTER_GEO = 2,
	TIGER_STRIPES = 3,
	GRADIENT_ACE = 4,
	TRI_TONE = 5,
	CARBON_GOLD = 6,
	CYBER_TRON = 7,
	METALLIC_CHROME = 8,
	HAZARD_CHEVRON = 9,
}

class JetSkinSpec extends Resource:
	@export var id: String = "factory"
	@export var display_name: String = "Factory Signature"
	@export var pattern_type: int = PatternType.SPLINTER_GEO
	@export var primary_color: Color = Color(0.28, 0.34, 0.42)
	@export var secondary_color: Color = Color(0.16, 0.20, 0.26)
	@export var tertiary_color: Color = Color(0.48, 0.56, 0.64)
	@export var accent_color: Color = Color(0.92, 0.22, 0.24)
	@export var radome_color: Color = Color(0.15, 0.17, 0.22)
	@export var canopy_tint: Color = Color(0.92, 0.72, 0.22)
	@export var metallic: float = 0.48
	@export var roughness: float = 0.32
	@export var emission_strength: float = 0.0

class WeaponSkinSpec extends Resource:
	@export var id: String = "stock"
	@export var display_name: String = "Stock Armory"
	@export var pattern_type: int = PatternType.TRI_TONE
	@export var body_color: Color = Color(0.84, 0.87, 0.91)
	@export var nose_color: Color = Color(0.28, 0.32, 0.38)
	@export var band_color: Color = Color(0.92, 0.70, 0.12)
	@export var fin_color: Color = Color(0.22, 0.26, 0.32)
	@export var metallic: float = 0.40
	@export var roughness: float = 0.30
	@export var emission_strength: float = 0.0

static var _custom_jet_skins: Dictionary = {}
static var _custom_weapon_skins: Dictionary = {}

static func get_jet_skin_presets() -> Array[JetSkinSpec]:
	return [
		_make_jet_skin("obsidian_crimson_gold", "Obsidian Crimson Gold", PatternType.CARBON_GOLD,
			Color("#14171f"), Color("#2a303c"), Color("#dc2626"), Color("#f59e0b"), Color("#111318"), Color("#ff3b4e"), 0.82, 0.22, 0.0),
		_make_jet_skin("cyber_plasma", "Cyber Plasma", PatternType.CYBER_TRON,
			Color("#0a1324"), Color("#164e63"), Color("#1e293b"), Color("#22d3ee"), Color("#082f49"), Color("#28a8ff"), 0.55, 0.26, 1.4),
		_make_jet_skin("arctic_ghost", "Arctic Ghost", PatternType.DIGITAL_PIXEL,
			Color("#dbe6f2"), Color("#64748b"), Color("#1e293b"), Color("#38bdf8"), Color("#334155"), Color("#28a8ff"), 0.28, 0.48, 0.0),
		_make_jet_skin("desert_viper", "Desert Viper", PatternType.TIGER_STRIPES,
			Color("#d4b483"), Color("#8a6642"), Color("#3b2d22"), Color("#f97316"), Color("#292524"), Color("#f0b83a"), 0.24, 0.44, 0.0),
		_make_jet_skin("royal_sovereign", "Royal Sovereign", PatternType.GRADIENT_ACE,
			Color("#0f172a"), Color("#1e40af"), Color("#312e81"), Color("#fbbf24"), Color("#1e293b"), Color("#f0b83a"), 0.72, 0.22, 0.0),
		_make_jet_skin("emerald_venom", "Emerald Venom", PatternType.SPLINTER_GEO,
			Color("#091016"), Color("#0f5e53"), Color("#10b981"), Color("#facc15"), Color("#18181b"), Color("#22f098"), 0.50, 0.28, 0.8),
		_make_jet_skin("titanium_solar", "Titanium Solar", PatternType.METALLIC_CHROME,
			Color("#94a3b8"), Color("#475569"), Color("#1e293b"), Color("#ef4444"), Color("#0f172a"), Color("#475569"), 0.92, 0.16, 0.0),
		_make_jet_skin("tri_tone_ace", "Tri-Tone Interceptor", PatternType.TRI_TONE,
			Color("#273240"), Color("#4a607a"), Color("#121720"), Color("#e11d48"), Color("#1c222b"), Color("#f0b83a"), 0.46, 0.32, 0.0),
	]

static func get_weapon_skin_presets() -> Array[WeaponSkinSpec]:
	return [
		_make_weapon_skin("ace_gold", "Obsidian Crimson Gold", PatternType.CARBON_GOLD,
			Color("#161922"), Color("#f59e0b"), Color("#dc2626"), Color("#272d3a"), 0.78, 0.22, 0.0),
		_make_weapon_skin("cyber_neon", "Cyber Neon", PatternType.CYBER_TRON,
			Color("#0b1426"), Color("#22d3ee"), Color("#a855f7"), Color("#1e293b"), 0.55, 0.24, 1.2),
		_make_weapon_skin("stealth_ram", "Stealth Obsidian", PatternType.TRI_TONE,
			Color("#181c24"), Color("#0f172a"), Color("#64748b"), Color("#111827"), 0.20, 0.54, 0.0),
		_make_weapon_skin("titanium_ace", "Brushed Titanium", PatternType.METALLIC_CHROME,
			Color("#b8c4d0"), Color("#334155"), Color("#ef4444"), Color("#475569"), 0.90, 0.18, 0.0),
		_make_weapon_skin("arctic_intercept", "Arctic Interceptor", PatternType.TIGER_STRIPES,
			Color("#e2e8f0"), Color("#0ea5e9"), Color("#1d4ed8"), Color("#1e293b"), 0.40, 0.30, 0.0),
		_make_weapon_skin("hazard_viper", "Hazard Viper", PatternType.HAZARD_CHEVRON,
			Color("#2c313a"), Color("#f97316"), Color("#facc15"), Color("#18181b"), 0.42, 0.32, 0.0),
		_make_weapon_skin("desert_tactical", "Desert Tactical", PatternType.GRADIENT_ACE,
			Color("#c9ad82"), Color("#7c2d12"), Color("#ea580c"), Color("#3b2f24"), 0.24, 0.44, 0.0),
	]

static func set_jet_skin(jet_id: String, skin: JetSkinSpec) -> void:
	_custom_jet_skins[jet_id] = skin

static func set_weapon_skin(weapon_id: String, skin: WeaponSkinSpec) -> void:
	_custom_weapon_skins[weapon_id] = skin

static func apply_jet_skin_to_all(jet_ids: Array, skin: JetSkinSpec) -> void:
	for jid in jet_ids:
		_custom_jet_skins[jid] = skin

static func clear_jet_skin(jet_id: String) -> void:
	_custom_jet_skins.erase(jet_id)

static func clear_weapon_skin(weapon_id: String) -> void:
	_custom_weapon_skins.erase(weapon_id)

static func get_active_jet_skin(spec: AircraftData) -> JetSkinSpec:
	if _custom_jet_skins.has(spec.id):
		return _custom_jet_skins[spec.id]
	var pat := PatternType.DIGITAL_PIXEL if spec.id == "s_57_felonis" else (
		PatternType.TIGER_STRIPES if spec.id in ["rf_3r_rafalis", "s_47_berkut_v"] else (
		PatternType.TWO_TONE if spec.id in ["kf_21m_borama", "ty_4_tempest"] else (
		PatternType.GRADIENT_ACE if spec.id == "f_35k_thunder" else PatternType.SPLINTER_GEO)))
	var rad := Color("#d8e0e8") if spec.id in ["s_35x_flanker_z", "s_34x_fullback_b"] else Color("#222830")
	return _make_jet_skin("factory_" + spec.id, "Factory Signature", pat,
		spec.livery_primary_color, spec.livery_secondary_color,
		spec.livery_primary_color.lerp(Color.WHITE, 0.22),
		spec.blueprint_accent_color, rad, Color(0.92, 0.72, 0.22), 0.46, 0.34, 0.0)

static func get_active_weapon_skin(weapon_id: String, default_pal: Dictionary) -> WeaponSkinSpec:
	if _custom_weapon_skins.has(weapon_id):
		return _custom_weapon_skins[weapon_id]
	return _make_weapon_skin("stock_" + weapon_id, "Stock Armory", PatternType.TRI_TONE,
		default_pal.get("body", Color(0.84, 0.87, 0.91)),
		default_pal.get("nose", Color(0.28, 0.32, 0.38)),
		default_pal.get("band", Color(0.92, 0.70, 0.12)),
		default_pal.get("fin", Color(0.22, 0.26, 0.32)), 0.38, 0.30, 0.0)

static func create_jet_shader_material(skin: JetSkinSpec) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/jet_skin_pbr.gdshader")
	mat.set_shader_parameter("pattern_type", skin.pattern_type)
	mat.set_shader_parameter("primary_color", skin.primary_color)
	mat.set_shader_parameter("secondary_color", skin.secondary_color)
	mat.set_shader_parameter("tertiary_color", skin.tertiary_color)
	mat.set_shader_parameter("accent_color", skin.accent_color)
	mat.set_shader_parameter("metallic_strength", skin.metallic)
	mat.set_shader_parameter("roughness_base", skin.roughness)
	mat.set_shader_parameter("emission_strength", skin.emission_strength)
	mat.set_shader_parameter("pattern_scale", 1.0)
	return mat

static func create_weapon_shader_material(skin: WeaponSkinSpec) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/jet_skin_pbr.gdshader")
	mat.set_shader_parameter("pattern_type", skin.pattern_type)
	mat.set_shader_parameter("primary_color", skin.body_color)
	mat.set_shader_parameter("secondary_color", skin.fin_color)
	mat.set_shader_parameter("tertiary_color", skin.nose_color)
	mat.set_shader_parameter("accent_color", skin.band_color)
	mat.set_shader_parameter("metallic_strength", skin.metallic)
	mat.set_shader_parameter("roughness_base", skin.roughness)
	mat.set_shader_parameter("emission_strength", skin.emission_strength)
	mat.set_shader_parameter("pattern_scale", 3.2)
	return mat

static func _make_jet_skin(id: String, dname: String, pat: int, c1: Color, c2: Color, c3: Color,
		acc: Color, rad: Color, can: Color, met: float, rgh: float, em: float) -> JetSkinSpec:
	var s := JetSkinSpec.new()
	s.id = id; s.display_name = dname; s.pattern_type = pat
	s.primary_color = c1; s.secondary_color = c2; s.tertiary_color = c3
	s.accent_color = acc; s.radome_color = rad; s.canopy_tint = can
	s.metallic = met; s.roughness = rgh; s.emission_strength = em
	return s

static func _make_weapon_skin(id: String, dname: String, pat: int, body: Color, nose: Color,
		band: Color, fin: Color, met: float, rgh: float, em: float) -> WeaponSkinSpec:
	var s := WeaponSkinSpec.new()
	s.id = id; s.display_name = dname; s.pattern_type = pat
	s.body_color = body; s.nose_color = nose; s.band_color = band; s.fin_color = fin
	s.metallic = met; s.roughness = rgh; s.emission_strength = em
	return s
