extends Node2D

# 메인 씬 - 모든 시스템 통합

@onready var game_manager = $GameManager
@onready var tower_placer = $TowerPlacer
@onready var game_ui = $GameUI
@onready var tower_menu: Control = $TowerMenu
@onready var game_over_ui: Control = $GameOverUI

func _ready() -> void:
	print("=== 메인 게임 씬 로드 시작 ===")

	# 타워 메뉴 확인 (중요!)
	print("tower_menu 변수 값: ", tower_menu)
	if tower_menu:
		print("TowerMenu 노드 찾음! 타입: ", tower_menu.get_class())
	else:
		print("ERROR: TowerMenu를 찾을 수 없습니다!")

	# 시스템 연결
	if game_manager:
		print("GameManager 찾음")
	else:
		print("ERROR: GameManager 없음!")
		return

	if tower_placer:
		tower_placer.set_game_manager(game_manager)
		print("TowerPlacer 연결됨")
	else:
		print("ERROR: TowerPlacer 없음!")

	if game_ui:
		game_ui.set_game_manager(game_manager)
		print("GameUI 연결됨")
	else:
		print("ERROR: GameUI 없음!")

	# 타워 메뉴 시그널 연결
	if tower_menu:
		tower_menu.upgrade_requested.connect(_on_tower_upgrade_requested)
		tower_menu.sell_requested.connect(_on_tower_sell_requested)
		print("TowerMenu 시그널 연결 완료!")
	else:
		print("ERROR: TowerMenu가 없어서 시그널 연결 불가!")

	# UI 버튼 시그널 연결
	if game_ui:
		game_ui.tower_button_pressed.connect(_on_tower_button_pressed)
		print("GameUI 시그널 연결됨")

	# 게임 매니저 시그널 연결
	if game_manager:
		game_manager.wave_completed.connect(_on_wave_completed)
		game_manager.game_over.connect(_on_game_over)
		print("GameManager 시그널 연결됨")

	# 타워 배치 시그널 연결
	if tower_placer:
		tower_placer.tower_placed.connect(_on_tower_placed)
		print("TowerPlacer 시그널 연결됨")

	# 초기 UI 업데이트
	update_ui()
	print("=== 메인 게임 씬 로드 완료 ===")

func _process(_delta: float) -> void:
	update_ui()

# 새로 배치된 타워에 시그널 연결
func _on_tower_placed(tower: Node2D) -> void:
	print("타워 배치됨: ", tower.name)
	if tower.has_signal("clicked"):
		if not tower.clicked.is_connected(_on_tower_clicked):
			tower.clicked.connect(_on_tower_clicked)
			print("타워 clicked 시그널 연결 완료")
	else:
		print("타워에 clicked 시그널이 없습니다!")

func _on_tower_clicked(tower: Node2D) -> void:
	print("타워 클릭됨: ", tower.name)
	if tower_menu:
		tower_menu.show_menu(tower)
	else:
		print("타워 메뉴가 없습니다!")

func _on_tower_upgrade_requested(tower: Node2D) -> void:
	var upgrade_cost = tower.get("upgrade_cost")
	if game_manager.spend_gold(upgrade_cost):
		tower.upgrade()
		print("타워 업그레이드! (비용: %d)" % upgrade_cost)
	else:
		print("업그레이드 비용 부족!")

func _on_tower_sell_requested(tower: Node2D) -> void:
	tower.sell()

func update_ui() -> void:
	if game_ui and game_manager:
		game_ui.update_gold(game_manager.current_gold)
		game_ui.update_lives(game_manager.current_lives)
		game_ui.update_wave(game_manager.current_wave)
		game_ui.update_score(game_manager.score)

func _on_tower_button_pressed() -> void:
	tower_placer.start_placing_tower()

func _on_wave_completed() -> void:
	print("웨이브 ", game_manager.current_wave, " 완료!")

func _on_game_over() -> void:
	print("게임 오버! 최종 점수: ", game_manager.score)
	# 게임 오버 UI 표시
	if game_over_ui:
		game_over_ui.show_game_over(game_manager.score, game_manager.current_wave)
	else:
		print("ERROR: GameOverUI를 찾을 수 없습니다!")
