extends Node2D

@export var scroll_speed := 90.0
@onready var player: Player = $Player
@onready var health_label: Label = $HUD/HealthLabel
@onready var parry_label: Label = $HUD/ParryLabel
@onready var run_label: Label = $HUD/RunLabel
@onready var run_progress: RunProgress = $RunProgress
@onready var level_label: Label = $HUD/LevelLabel
@onready var experience_label: Label = $HUD/ExperienceLabel
@onready var experience_bar: ProgressBar = $HUD/ExperienceBar
@onready var card_manager: CardManager = $CardManager
@onready var card_slots_hud: CardSlotsHud = $HUD/CardPanel
@onready var shop_manager: ShopManager = $ShopManager
@onready var shop_ui: ShopUI = $HUD/ShopUI
@onready var pause_menu: PauseMenu = $HUD/PauseMenu
@onready var drone_formation: DroneFormation = $DroneFormation
@onready var boss_manager: BossManager = $BossManager

var stars: Array[Polygon2D] = []
var _stage_elapsed := 0.0
var _stage: StageData


func _ready() -> void:
	_apply_selected_stage()
	_create_starfield()
	player.health_changed.connect(_on_player_health_changed)
	player.parry_state_changed.connect(_on_parry_state_changed)
	player.died.connect(_on_player_died)
	card_manager.cards_changed.connect(card_slots_hud.show_cards)
	card_manager.card_rejected.connect(_on_card_rejected)
	card_manager.configure(player)
	drone_formation.configure(player, card_manager)
	SynergyManager.synergy_unlocked.connect(_on_synergy_unlocked)
	boss_manager.boss_started.connect(_on_boss_started)
	boss_manager.boss_health_changed.connect(_on_boss_health_changed)
	boss_manager.boss_phase_changed.connect(_on_boss_phase_changed)
	boss_manager.boss_defeated.connect(_on_boss_defeated)
	shop_manager.configure(card_manager)
	shop_manager.shop_requested.connect(shop_ui.open_shop)
	shop_ui.configure(card_manager, card_slots_hud)
	pause_menu.restart_requested.connect(func() -> void: get_tree().reload_current_scene())
	pause_menu.main_menu_requested.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	run_progress.level_changed.connect(_on_level_changed)
	run_progress.experience_changed.connect(_on_experience_changed)
	_on_player_health_changed(player.health, player.max_health)
	_on_level_changed(run_progress.level)
	_on_experience_changed(run_progress.experience, run_progress.experience_required)
	var test_boss := StageManager.consume_boss_test()
	if test_boss != null:
		boss_manager.call_deferred("start_boss", test_boss)


func _apply_selected_stage() -> void:
	_stage = StageManager.get_stage()
	$Background.color = _stage.background_color
	$EnemySpawner.waves = _stage.waves


func _process(delta: float) -> void:
	if not player.is_dead and not boss_manager.is_boss_active:
		_stage_elapsed += delta
		if _stage != null and _stage_elapsed >= _stage.target_duration:
			boss_manager.start_boss(_stage.boss_scene)
	for star in stars:
		star.position.y += scroll_speed * delta
		if star.position.y > 880.0:
			star.position.y = -20.0


func _create_starfield() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 42
	for index in 42:
		var star := Polygon2D.new()
		var size := random.randf_range(1.0, 2.8)
		star.polygon = PackedVector2Array([Vector2(-size, 0), Vector2(0, -size), Vector2(size, 0), Vector2(0, size)])
		star.position = Vector2(random.randf_range(0.0, 480.0), random.randf_range(-20.0, 880.0))
		star.color = Color(0.28, 0.45, 0.75, random.randf_range(0.35, 0.9))
		$ScrollLayer/Starfield.add_child(star)
		stars.append(star)


func _on_player_health_changed(current_health: int, maximum_health: int) -> void:
	health_label.text = "Hull: %d / %d" % [current_health, maximum_health]


func _on_parry_state_changed(is_active: bool) -> void:
	parry_label.text = "PARRY ACTIVE" if is_active else "PARRY READY"
	parry_label.modulate = Color(1.0, 0.94, 0.35) if is_active else Color(0.45, 0.85, 1.0)


func _on_player_died() -> void:
	$EnemySpawner.set_active(false)
	card_manager.reset_run_cards()
	run_label.text = "SHIP DESTROYED\nPress R to restart"


func _on_card_rejected(_card: CardData) -> void:
	if not player.is_dead:
		run_label.text = "CARD SLOTS FULL"
		var timer := get_tree().create_timer(1.0)
		timer.timeout.connect(func() -> void:
			if not player.is_dead:
				run_label.text = "")


func _on_level_changed(level: int) -> void:
	level_label.text = "Run level: %d" % level
	if level > 1 and level % 5 == 0 and not player.is_dead:
		shop_manager.request_shop(level)


func _on_experience_changed(current_experience: int, required_experience: int) -> void:
	experience_label.text = "XP: %d / %d" % [current_experience, required_experience]
	experience_bar.max_value = required_experience
	experience_bar.value = current_experience


func _on_synergy_unlocked(synergy: SynergyData) -> void:
	var notice := $HUD/SynergyNotice
	notice.text = "SYNERGY UNLOCKED\n%s" % synergy.display_name
	notice.visible = true
	notice.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(notice, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void: notice.visible = false)


func _on_boss_started(boss: Boss) -> void:
	$HUD/BossPanel.visible = true
	$HUD/BossPanel/Name.text = boss.boss_display_name
	run_label.text = "WARNING: %s" % boss.boss_display_name


func _on_boss_health_changed(current: int, maximum: int) -> void:
	$HUD/BossPanel/Health.max_value = maximum
	$HUD/BossPanel/Health.value = current


func _on_boss_phase_changed(phase: int, phase_count: int) -> void:
	$HUD/BossPanel/Phase.text = "PHASE %d / %d" % [phase, phase_count]


func _on_boss_defeated(boss_id: String) -> void:
	$HUD/BossPanel.visible = false
	run_label.text = "%s DEFEATED" % boss_id.to_upper()
	SaveManager.mark_boss_defeated(boss_id)
	if boss_id == "boss_1":
		SaveManager.unlock_stage("stage_2")
	elif boss_id == "boss_2":
		SaveManager.unlock_stage("stage_3")
	var rewards := BossRewardData.get_cards(boss_id)
	if not rewards.is_empty():
		shop_ui.open_boss_reward(rewards)


func _unhandled_input(event: InputEvent) -> void:
	if not player.is_dead and not shop_ui.visible and event.is_action_pressed("ui_cancel"):
		pause_menu.open_menu()
		get_viewport().set_input_as_handled()
		return
	if player.is_dead and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	elif player.is_dead and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
	# Temporary card testing bridge; remove once the shop supplies cards.
	elif not player.is_dead and event is InputEventKey and event.pressed and not event.echo:
		var test_key_to_index := {KEY_1: 0, KEY_2: 1, KEY_3: 2, KEY_4: 3, KEY_5: 4}
		if test_key_to_index.has(event.keycode):
			card_manager.add_test_card(test_key_to_index[event.keycode])
		elif event.keycode == KEY_T and not shop_ui.visible:
			shop_manager.request_shop(run_progress.level)
		elif event.keycode == KEY_B and not shop_ui.visible:
			boss_manager.start_boss(_stage.boss_scene if _stage != null else null)
