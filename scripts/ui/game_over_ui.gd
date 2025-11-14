extends CanvasLayer

# 게임 오버 UI - Bloons TD 스타일

@onready var game_over_label: Label = $Container/CenterContainer/GameOverLabel
@onready var final_score_label: Label = $Container/CenterContainer/FinalScoreLabel
@onready var retry_button: Button = $Container/CenterContainer/ButtonContainer/RetryButton
@onready var main_menu_button: Button = $Container/CenterContainer/ButtonContainer/MainMenuButton

func _ready() -> void:
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()  # 시작할 때는 숨김

func show_game_over(final_score: int, wave: int) -> void:
	if final_score_label:
		final_score_label.text = "최종 점수: %d\n웨이브: %d" % [final_score, wave]

	show()

	# 게임 일시정지
	get_tree().paused = true

	print("게임 오버! 최종 점수: %d, 웨이브: %d" % [final_score, wave])

func _on_retry_pressed() -> void:
	print("게임 재시작")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	print("메인 메뉴로 돌아가기")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
