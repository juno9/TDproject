extends Control

# 게임 오버 UI

@onready var final_score_label: Label = $Panel/VBoxContainer/FinalScoreLabel
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	hide()  # 시작할 때는 숨김

func show_game_over(final_score: int, wave: int) -> void:
	final_score_label.text = "게임 오버!\n최종 점수: %d\n웨이브: %d" % [final_score, wave]
	show()
	# 게임 일시정지
	get_tree().paused = true

func _on_main_menu_pressed() -> void:
	print("메인 메뉴로 돌아가기")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_retry_pressed() -> void:
	print("게임 재시작")
	get_tree().paused = false
	get_tree().reload_current_scene()
