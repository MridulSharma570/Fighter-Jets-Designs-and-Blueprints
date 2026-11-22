extends Node
## Autoload Singleton: UpgradeManager
## Handles Level 1-20 progression for Fighter Jets, Missiles, Rockets, Cannons,
## plus Special Overdrive Tiers (Lv 1-3) and Blueprint/Silver economy.

signal item_upgraded(category: String, item_id: String, new_level: int)
signal currency_changed(silver: int, alloy: int)

const MAX_ITEM_LEVEL := 20
const MAX_ABILITY_LEVEL := 3
const SAVE_PATH := "user://sky_dominion_progression.json"

var silver_credits: int = 125000
var titanium_alloy: int = 4500

var jet_levels: Dictionary = {}
var jet_ability_levels: Dictionary = {}
var missile_levels: Dictionary = {}
var rocket_levels: Dictionary = {}
var cannon_levels: Dictionary = {}
var blueprint_shards: Dictionary = {}

func _ready() -> void:
	_init_defaults()
	load_progress()

func _init_defaults() -> void:
	for jet_id in ["s_57_felonis", "j_20x_wyvern", "f_22v_talon", "f_35k_thunder",
			"kf_21m_borama", "ty_4_tempest", "s_47_berkut_v", "s_35x_flanker_z",
			"rf_3r_rafalis", "s_34x_fullback_b"]:
		jet_levels[jet_id] = 1
		jet_ability_levels[jet_id] = 1
		blueprint_shards[jet_id] = 30

func get_jet_level(jet_id: String) -> int:
	return clampi(jet_levels.get(jet_id, 1), 1, MAX_ITEM_LEVEL)

func get_ability_level(jet_id: String) -> int:
	var j_lv := get_jet_level(jet_id)
	var unlocked_cap := 1
	if j_lv >= 8:
		unlocked_cap = 2
	if j_lv >= 16:
		unlocked_cap = 3
	return clampi(jet_ability_levels.get(jet_id, 1), 1, unlocked_cap)

func get_missile_level(missile_id: String) -> int:
	return clampi(missile_levels.get(missile_id, 1), 1, MAX_ITEM_LEVEL)

func get_rocket_level(rocket_id: String) -> int:
	return clampi(rocket_levels.get(rocket_id, 1), 1, MAX_ITEM_LEVEL)

func get_cannon_level(cannon_id: String) -> int:
	return clampi(cannon_levels.get(cannon_id, 1), 1, MAX_ITEM_LEVEL)

func get_upgrade_cost(category: String, current_level: int) -> Dictionary:
	var lv := clampi(current_level, 1, MAX_ITEM_LEVEL)
	var mult := 1.0
	match category:
		"jet": mult = 1.6
		"missile": mult = 1.15
		"rocket": mult = 0.9
		"cannon": mult = 1.05
	var silver_cost := int(round(650.0 * pow(1.24, lv - 1) * mult))
	var alloy_cost := int(round(15.0 * pow(1.18, lv - 1) * mult))
	var shards_cost := maxi(2, int(lv * 1.5)) if category == "jet" else 0
	return {
		"silver": silver_cost,
		"alloy": alloy_cost,
		"shards": shards_cost,
	}

func can_upgrade(category: String, item_id: String) -> bool:
	var cur := _get_level_by_category(category, item_id)
	if cur >= MAX_ITEM_LEVEL:
		return false
	var cost := get_upgrade_cost(category, cur)
	if silver_credits < cost["silver"] or titanium_alloy < cost["alloy"]:
		return false
	if category == "jet" and blueprint_shards.get(item_id, 0) < cost["shards"]:
		return false
	return true

func upgrade_item(category: String, item_id: String) -> bool:
	if not can_upgrade(category, item_id):
		return false
	var cur := _get_level_by_category(category, item_id)
	var cost := get_upgrade_cost(category, cur)
	silver_credits -= cost["silver"]
	titanium_alloy -= cost["alloy"]
	if category == "jet":
		blueprint_shards[item_id] = blueprint_shards.get(item_id, 0) - cost["shards"]
	var next_lv := cur + 1
	_set_level_by_category(category, item_id, next_lv)

	if category == "jet":
		if next_lv >= 8 and jet_ability_levels.get(item_id, 1) < 2:
			jet_ability_levels[item_id] = 2
		if next_lv >= 16 and jet_ability_levels.get(item_id, 1) < 3:
			jet_ability_levels[item_id] = 3

	currency_changed.emit(silver_credits, titanium_alloy)
	item_upgraded.emit(category, item_id, next_lv)
	save_progress()
	return true

func _get_level_by_category(category: String, item_id: String) -> int:
	match category:
		"jet": return get_jet_level(item_id)
		"missile": return get_missile_level(item_id)
		"rocket": return get_rocket_level(item_id)
		"cannon": return get_cannon_level(item_id)
	return 1

func _set_level_by_category(category: String, item_id: String, lv: int) -> void:
	match category:
		"jet": jet_levels[item_id] = lv
		"missile": missile_levels[item_id] = lv
		"rocket": rocket_levels[item_id] = lv
		"cannon": cannon_levels[item_id] = lv

func save_progress() -> void:
	var data := {
		"silver_credits": silver_credits,
		"titanium_alloy": titanium_alloy,
		"jet_levels": jet_levels,
		"jet_ability_levels": jet_ability_levels,
		"missile_levels": missile_levels,
		"rocket_levels": rocket_levels,
		"cannon_levels": cannon_levels,
		"blueprint_shards": blueprint_shards,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	silver_credits = int(parsed.get("silver_credits", silver_credits))
	titanium_alloy = int(parsed.get("titanium_alloy", titanium_alloy))
	jet_levels.merge(parsed.get("jet_levels", {}), true)
	jet_ability_levels.merge(parsed.get("jet_ability_levels", {}), true)
	missile_levels.merge(parsed.get("missile_levels", {}), true)
	rocket_levels.merge(parsed.get("rocket_levels", {}), true)
	cannon_levels.merge(parsed.get("cannon_levels", {}), true)
	blueprint_shards.merge(parsed.get("blueprint_shards", {}), true)
