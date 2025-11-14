extends CanvasLayer

# 게임 UI - Bloons TD 스타일

signal tower_button_pressed
signal settings_button_pressed
signal upgrades_button_pressed

@onready var lives_label: Label = $TopLeftPanel/LivesContainer/LivesLabel
@onready var gold_label: Label = $TopLeftPanel/GoldContainer/GoldLabel
@onready var round_label: Label = $TopRightPanel/RoundContainer/RoundLabel
@onready var settings_button: Button = $TopRightPanel/SettingsButton
@onready var upgrades_button: Button = $TopRightPanel/UpgradesButton
@onready var tower_grid: GridContainer = $RightPanel/VBoxContainer/TowerGrid
@onready var special_ability_button: Button = $BottomPanel/SpecialAbilityButton
@onready var play_pause_button: Button = $BottomPanel/PlayPauseButton
@onready var hint_label: Label = $HintLabel

var game_manager: Node = null
var is_speed_doubled: bool = false
var max_waves: int = 40

func _ready() -> void:
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if upgrades_button:
		upgrades_button.pressed.connect(_on_upgrades_pressed)
	if play_pause_button:
		play_pause_button.pressed.connect(_on_play_pause_pressed)
	if special_ability_button:
		special_ability_button.pressed.connect(_on_special_ability_pressed)

	# 타워 그리드에 임시 타워 버튼들 추가 (나중에 동적으로 생성)
	_create_tower_buttons()

func set_game_manager(manager: Node) -> void:
	game_manager = manager

func update_gold(amount: int) -> void:
	if gold_label:
		gold_label.text = "$" + _format_number(amount)

func update_lives(amount: int) -> void:
	if lives_label:
		lives_label.text = str(amount)

func update_wave(wave: int) -> void:
	if round_label:
		round_label.text = str(wave) + "/" + str(max_waves)

func update_score(_score: int) -> void:
	# 점수는 별도로 표시하지 않음 (Bloons TD 스타일)
	pass

func _format_number(num: int) -> String:
	var str_num = str(num)
	var result = ""
	var count = 0

	for i in range(str_num.length() - 1, -1, -1):
		if count == 3:
			result = "," + result
			count = 0
		result = str_num[i] + result
		count += 1

	return result

func _create_tower_buttons() -> void:
	# 임시 타워 버튼들 (6개)
	var tower_data = [
		{"name": "기본", "cost": 160, "emoji": "🐵"},
		{"name": "빠른", "cost": 170, "emoji": "🦧"},
		{"name": "폭탄", "cost": 275, "emoji": "💣"},
		{"name": "대포", "cost": 445, "emoji": "💥"},
		{"name": "얼음", "cost": 240, "emoji": "❄️"},
		{"name": "얼음2", "cost": 425, "emoji": "🧊"}
	]

	for data in tower_data:
		var button = Button.new()
		button.custom_minimum_size = Vector2(55, 70)

		# 버튼 텍스트 (이모지 + 가격)
		button.text = data.emoji + "\n$" + str(data.cost)
		button.pressed.connect(_on_tower_button_pressed.bind(data.name))

		tower_grid.add_child(button)

func _on_tower_button_pressed(_tower_type: String = "") -> void:
	tower_button_pressed.emit()
	show_hint("타워 배치: 좌클릭-배치 / 우클릭-취소", 3.0)

func _on_settings_pressed() -> void:
	settings_button_pressed.emit()
	print("설정 버튼 클릭")

func _on_upgrades_pressed() -> void:
	upgrades_button_pressed.emit()
	print("업그레이드 버튼 클릭")

func _on_play_pause_pressed() -> void:
	is_speed_doubled = not is_speed_doubled

	if is_speed_doubled:
		Engine.time_scale = 2.0
		play_pause_button.text = "▶▶▶"
		play_pause_button.modulate = Color(1, 0.5, 0, 1)  # 주황색
	else:
		Engine.time_scale = 1.0
		play_pause_button.text = "▶▶"
		play_pause_button.modulate = Color(0.2, 1, 0.2)  # 녹색

	print("게임 속도: ", Engine.time_scale, "배")

func _on_special_ability_pressed() -> void:
	print("특수 능력 사용")
	show_hint("특수 능력 활성화!", 2.0)

func show_hint(message: String, duration: float = 2.0) -> void:
	if hint_label:
		hint_label.text = message
		hint_label.visible = true

		# 일정 시간 후 숨김
		await get_tree().create_timer(duration).timeout
		if hint_label:
			hint_label.visible = false

func hide_hint() -> void:
	if hint_label:
		hint_label.visible = false
