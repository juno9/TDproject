extends CanvasLayer

# 게임 UI - 골드, 생명, 웨이브, 타워 버튼 표시

signal tower_button_pressed

@onready var gold_label: Label = $Panel/VBoxContainer/GoldLabel
@onready var lives_label: Label = $Panel/VBoxContainer/LivesLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var tower_button: Button = $Panel/VBoxContainer/TowerButton
@onready var hint_label: Label = $HintLabel
@onready var speed_button: Button = $SpeedButton

var game_manager: Node = null
var is_speed_doubled: bool = false

func _ready() -> void:
	if tower_button:
		tower_button.pressed.connect(_on_tower_button_pressed)
	if speed_button:
		speed_button.pressed.connect(_on_speed_button_pressed)

func set_game_manager(manager: Node) -> void:
	game_manager = manager

func update_gold(amount: int) -> void:
	if gold_label:
		gold_label.text = "골드: " + str(amount)

func update_lives(amount: int) -> void:
	if lives_label:
		lives_label.text = "생명: " + str(amount)

func update_wave(wave: int) -> void:
	if wave_label:
		wave_label.text = "웨이브: " + str(wave)

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "점수: " + str(score)

func _on_tower_button_pressed() -> void:
	tower_button_pressed.emit()
	show_hint("타워 배치: 좌클릭-배치 / 우클릭-취소", 3.0)

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

func _on_speed_button_pressed() -> void:
	is_speed_doubled = not is_speed_doubled

	if is_speed_doubled:
		Engine.time_scale = 2.0
		speed_button.text = "X2"
	else:
		Engine.time_scale = 1.0
		speed_button.text = "X1"

	print("게임 속도 변경: ", Engine.time_scale)
