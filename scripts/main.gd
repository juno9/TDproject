extends Node2D

# 메인 씬 - 모든 시스템 통합

@onready var game_manager = $GameManager
@onready var tower_placer = $TowerPlacer
@onready var game_ui = $GameUI
@onready var tower_menu: Control = $TowerMenu
@onready var upgrade_panel: CanvasLayer = $UpgradePanel
@onready var game_over_ui: CanvasLayer = $GameOverUI
@onready var game_clear_ui: CanvasLayer = $GameClearUI

var selected_tower: Node2D = null  # 현재 선택된 타워

func _ready() -> void:
	print("=== 메인 게임 씬 로드 시작 ===")

	# UI 노드들 확인
	print("tower_menu 변수 값: ", tower_menu)
	print("upgrade_panel 변수 값: ", upgrade_panel)
	print("game_over_ui 변수 값: ", game_over_ui)

	if tower_menu:
		print("TowerMenu 노드 찾음! 타입: ", tower_menu.get_class())
	else:
		print("ERROR: TowerMenu를 찾을 수 없습니다!")

	if upgrade_panel:
		print("UpgradePanel 노드 찾음! 타입: ", upgrade_panel.get_class())
	else:
		print("ERROR: UpgradePanel을 찾을 수 없습니다!")

	if game_over_ui:
		print("GameOverUI 노드 찾음! 타입: ", game_over_ui.get_class())
	else:
		print("ERROR: GameOverUI를 찾을 수 없습니다!")

	if game_clear_ui:
		print("GameClearUI 노드 찾음! 타입: ", game_clear_ui.get_class())
	else:
		print("ERROR: GameClearUI를 찾을 수 없습니다!")

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
		tower_menu.upgrade_requested.connect(_on_tower_upgrade_menu_pressed)
		tower_menu.sell_requested.connect(_on_tower_sell_requested)
		print("TowerMenu 시그널 연결 완료!")
	else:
		print("ERROR: TowerMenu가 없어서 시그널 연결 불가!")

	# 업그레이드 패널 시그널 연결
	if upgrade_panel:
		upgrade_panel.upgrade_requested.connect(_on_stat_upgrade_requested)
		upgrade_panel.sell_requested.connect(_on_tower_sell_requested)
		print("UpgradePanel 시그널 연결 완료!")
	else:
		print("ERROR: UpgradePanel가 없어서 시그널 연결 불가!")

	# UI 버튼 시그널 연결
	if game_ui:
		game_ui.tower_button_pressed.connect(_on_tower_button_pressed)
		game_ui.upgrades_button_pressed.connect(_on_upgrades_button_pressed)
		print("GameUI 시그널 연결됨")

	# 게임 매니저 시그널 연결
	if game_manager:
		game_manager.wave_completed.connect(_on_wave_completed)
		game_manager.game_over.connect(_on_game_over)
		game_manager.game_clear.connect(_on_game_clear)
		print("GameManager 시그널 연결됨")

	# 타워 배치 시그널 연결
	if tower_placer:
		tower_placer.tower_placed.connect(_on_tower_placed)
		print("TowerPlacer 시그널 연결됨")

	# 초기 UI 업데이트
	update_ui()
	print("=== 메인 게임 씬 로드 완료 ===")

func _input(event: InputEvent) -> void:
	# 디버깅용: G 키로 게임 오버 UI 테스트
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		print("디버그: 게임 오버 UI 강제 표시")
		if game_over_ui:
			game_over_ui.show_game_over(100, 5)
		else:
			print("ERROR: game_over_ui가 없습니다!")

	# 디버깅용: U 키로 업그레이드 패널 테스트
	if event is InputEventKey and event.pressed and event.keycode == KEY_U:
		print("디버그: 업그레이드 패널 강제 표시")
		if upgrade_panel:
			# 임시 타워 생성해서 테스트
			var test_tower = Node2D.new()
			test_tower.set_script(load("res://scripts/tower.gd"))
			upgrade_panel.show_panel(test_tower)
		else:
			print("ERROR: upgrade_panel이 없습니다!")

func _process(_delta: float) -> void:
	update_ui()

func _unhandled_input(event: InputEvent) -> void:
	# 배경 클릭 시 타워 선택 해제
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_tower and is_instance_valid(selected_tower):
			print("배경 클릭 - 타워 선택 해제")
			selected_tower.modulate = Color(1, 1, 1, 1)
			if selected_tower.has_node("RangeIndicator"):
				selected_tower.get_node("RangeIndicator").visible = false
			selected_tower = null

# 새로 배치된 타워에 시그널 연결
func _on_tower_placed(tower: Node2D) -> void:
	print("타워 배치됨: ", tower.name)
	if tower.has_signal("clicked"):
		if not tower.clicked.is_connected(_on_tower_clicked):
			tower.clicked.connect(_on_tower_clicked)
			print("타워 clicked 시그널 연결 완료")
	else:
		print("타워에 clicked 시그널이 없습니다!")

	# 타워 배치 후 타워 메뉴 숨기기
	if tower_menu and tower_menu.visible:
		tower_menu.hide()

func _on_tower_clicked(tower: Node2D) -> void:
	print("타워 클릭됨: ", tower.name)

	# 이전에 선택된 타워의 강조 해제
	if selected_tower and is_instance_valid(selected_tower):
		selected_tower.modulate = Color(1, 1, 1, 1)  # 원래 색상으로
		# 사정거리 인디케이터 숨김
		if selected_tower.has_node("RangeIndicator"):
			selected_tower.get_node("RangeIndicator").visible = false

	# 새로운 타워 선택
	selected_tower = tower

	# 선택된 타워 강조
	if selected_tower:
		selected_tower.modulate = Color(1.3, 1.3, 0.7, 1)  # 노란빛 강조
		print("타워 선택됨: ", selected_tower.name)

		# 사정거리 인디케이터 표시
		if selected_tower.has_node("RangeIndicator"):
			selected_tower.get_node("RangeIndicator").visible = true
			print("사정거리 인디케이터 표시")

		# 타워 메뉴는 표시하지 않음 (팝업 제거)
		# if tower_menu:
		#     tower_menu.show_menu(tower)

func _on_tower_upgrade_menu_pressed(tower: Node2D) -> void:
	# 타워 메뉴의 업그레이드 버튼 클릭 시 -> 업그레이드 패널 열기
	print("=== _on_tower_upgrade_menu_pressed 호출됨 ===")
	print("타워: ", tower)
	print("upgrade_panel: ", upgrade_panel)

	if upgrade_panel:
		print("업그레이드 패널 show_panel 호출")
		upgrade_panel.show_panel(tower)
		# 타워 메뉴는 숨기기
		if tower_menu:
			print("타워 메뉴 숨기기")
			tower_menu.hide()
	else:
		print("ERROR: UpgradePanel을 찾을 수 없습니다!")

func _on_stat_upgrade_requested(tower: Node2D, upgrade_type: String) -> void:
	# 업그레이드 패널에서 특정 스탯 업그레이드 요청
	const UPGRADE_COST = 50

	if game_manager.spend_gold(UPGRADE_COST):
		if tower.has_method("upgrade_stat"):
			tower.upgrade_stat(upgrade_type)
			print("타워 %s 업그레이드! (비용: %d)" % [upgrade_type, UPGRADE_COST])
		else:
			print("ERROR: 타워에 upgrade_stat 메서드가 없습니다!")
	else:
		print("업그레이드 비용 부족!")
		if game_ui:
			game_ui.show_hint("골드가 부족합니다!", 2.0)

func _on_tower_sell_requested(tower: Node2D) -> void:
	print("타워 판매: ", tower)

	# 선택 해제
	if selected_tower == tower:
		selected_tower = null

	# 타워 판매 (환불 포함)
	tower.sell()

func update_ui() -> void:
	if game_ui and game_manager:
		game_ui.update_gold(game_manager.current_gold)
		game_ui.update_lives(game_manager.current_lives)
		game_ui.update_wave(game_manager.current_wave)
		game_ui.update_score(game_manager.score)

func _on_tower_button_pressed() -> void:
	tower_placer.start_placing_tower()

func _on_upgrades_button_pressed() -> void:
	print("=== UPGRADES 버튼 클릭 ===")
	print("선택된 타워: ", selected_tower)

	if selected_tower and is_instance_valid(selected_tower):
		print("업그레이드 패널 표시")
		if upgrade_panel:
			upgrade_panel.show_panel(selected_tower)
		else:
			print("ERROR: UpgradePanel을 찾을 수 없습니다!")
	else:
		print("선택된 타워가 없습니다!")
		if game_ui:
			game_ui.show_hint("먼저 타워를 선택하세요!", 2.0)

func _on_wave_completed() -> void:
	print("웨이브 ", game_manager.current_wave, " 완료!")

func _on_game_over() -> void:
	print("게임 오버! 최종 점수: ", game_manager.score)
	# 게임 오버 UI 표시
	if game_over_ui:
		game_over_ui.show_game_over(game_manager.score, game_manager.current_wave)
	else:
		print("ERROR: GameOverUI를 찾을 수 없습니다!")

func _on_game_clear() -> void:
	print("게임 클리어! 최종 점수: ", game_manager.score)
	# 게임 클리어 UI 표시
	if game_clear_ui:
		game_clear_ui.show_game_clear(game_manager.score, game_manager.current_wave)
	else:
		print("ERROR: GameClearUI를 찾을 수 없습니다!")
