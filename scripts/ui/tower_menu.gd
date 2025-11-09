extends Control

# 타워 메뉴 UI - 업그레이드, 판매 버튼 관리

signal upgrade_requested(tower)
signal sell_requested(tower)

var selected_tower: Node2D = null

@onready var upgrade_button: Button = $Panel/VBoxContainer/UpgradeButton
@onready var sell_button: Button = $Panel/VBoxContainer/SellButton

func _ready() -> void:
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	hide() # 처음에는 숨김

func show_menu(tower: Node2D) -> void:
	print("타워 메뉴 표시 시도: ", tower.name if tower else "null")
	selected_tower = tower
	if not is_instance_valid(selected_tower):
		print("타워가 유효하지 않음")
		hide()
		return

	# 타워 위치 근처에 메뉴 표시
	position = selected_tower.global_position + Vector2(0, -80)

	# 업그레이드 비용 표시 및 버튼 활성화/비활성화
	var upgrade_cost: int = selected_tower.get("upgrade_cost") if is_instance_valid(selected_tower) else 0
	upgrade_button.text = "업그레이드 (%dG)" % upgrade_cost
	upgrade_button.disabled = not selected_tower.can_upgrade()

	# 판매 가격 표시
	var sell_price = floori(selected_tower.get("cost") * 0.7)
	sell_button.text = "판매 (%dG)" % sell_price

	print("타워 메뉴 표시 완료 at position: ", position)
	show()

func _on_upgrade_pressed() -> void:
	if is_instance_valid(selected_tower):
		upgrade_requested.emit(selected_tower)
	hide()

func _on_sell_pressed() -> void:
	if is_instance_valid(selected_tower):
		sell_requested.emit(selected_tower)
	hide()

func _unhandled_input(event: InputEvent) -> void:
	# UI 바깥을 클릭하면 메뉴 숨김
	if event is InputEventMouseButton and event.pressed and visible:
		if not get_rect().has_point(get_local_mouse_position()):
			hide()
