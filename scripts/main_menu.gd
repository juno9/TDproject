extends Control

# 메인 메뉴 화면

@onready var start_button: Button = $StartButton
@onready var settings_button: Button = $SettingsButton
@onready var exit_button: Button = $ExitButton

func _ready() -> void:
	print("메인 메뉴 _ready 실행")
	# 버튼 시그널 연결
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		print("시작 버튼 연결됨")
	else:
		print("시작 버튼을 찾을 수 없음!")
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	print("게임 시작 버튼 눌림!")
	# 게임 씬으로 전환
	var error = get_tree().change_scene_to_file("res://scenes/main.tscn")
	if error != OK:
		print("씬 전환 실패! 에러 코드: ", error)
	else:
		print("씬 전환 성공!")

func _on_settings_button_pressed() -> void:
	print("설정 화면 (미구현)")
	# TODO: 설정 화면으로 전환
	# get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_exit_button_pressed() -> void:
	print("게임 종료")
	# 게임 종료
	get_tree().quit()
