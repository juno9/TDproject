extends CanvasLayer

# 게임 클리어 UI

signal main_menu_pressed

@onready var game_clear_label: Label = $Container/CenterContainer/GameClearLabel
@onready var final_score_label: Label = $Container/CenterContainer/FinalScoreLabel
@onready var final_wave_label: Label = $Container/CenterContainer/FinalWaveLabel
@onready var main_menu_button: Button = $Container/CenterContainer/ButtonContainer/MainMenuButton

func _ready() -> void:
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()

func show_game_clear(score: int, wave: int) -> void:
	print("=== 게임 클리어 UI 표시 ===")
	print("최종 점수: ", score)
	print("최종 웨이브: ", wave)

	if final_score_label:
		final_score_label.text = "최종 점수: %d" % score
	if final_wave_label:
		final_wave_label.text = "클리어한 웨이브: %d" % wave

	show()
	print("GameClearUI visible 상태: ", visible)

	# 게임 일시정지
	get_tree().paused = true

func _on_main_menu_pressed() -> void:
	print("메인 메뉴 버튼 클릭")
	main_menu_pressed.emit()
	# 게임 일시정지 해제
	get_tree().paused = false
	# 메인 메뉴 씬으로 전환
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
