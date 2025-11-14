extends CanvasLayer

# 타워 업그레이드 선택 패널

signal upgrade_requested(tower, upgrade_type)
signal sell_requested(tower)

var selected_tower: Node2D = null

@onready var container: Control = $Container
@onready var tower_info_label: Label = $Container/Panel/VBoxContainer/TowerInfoLabel
@onready var attack_speed_button: Button = $Container/Panel/VBoxContainer/AttackSpeedButton
@onready var attack_damage_button: Button = $Container/Panel/VBoxContainer/AttackDamageButton
@onready var range_button: Button = $Container/Panel/VBoxContainer/RangeButton
@onready var sell_button: Button = $Container/Panel/VBoxContainer/SellButton
@onready var close_button: Button = $Container/Panel/VBoxContainer/CloseButton

const UPGRADE_COST_SPEED = 50
const UPGRADE_COST_DAMAGE = 50
const UPGRADE_COST_RANGE = 50

func _ready() -> void:
	if attack_speed_button:
		attack_speed_button.pressed.connect(_on_attack_speed_pressed)
	if attack_damage_button:
		attack_damage_button.pressed.connect(_on_attack_damage_pressed)
	if range_button:
		range_button.pressed.connect(_on_range_pressed)
	if sell_button:
		sell_button.pressed.connect(_on_sell_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	hide()

func show_panel(tower: Node2D) -> void:
	print("=== UpgradePanel.show_panel 호출됨 ===")
	print("타워: ", tower)
	print("타워 유효성: ", is_instance_valid(tower))

	if not is_instance_valid(tower):
		print("타워가 유효하지 않음, 패널 숨김")
		hide()
		return

	selected_tower = tower

	# 타워 정보 표시
	var tower_level = tower.get("level") if tower.has_method("get") else 1
	tower_info_label.text = "타워 레벨: %d" % tower_level
	print("타워 레벨: ", tower_level)

	# 각 업그레이드 버튼 정보 업데이트
	_update_button_info()

	print("UpgradePanel.show() 호출")
	show()
	print("UpgradePanel visible 상태: ", visible)

func _update_button_info() -> void:
	if not is_instance_valid(selected_tower):
		return

	var speed = selected_tower.get("attack_speed") if selected_tower.has_method("get") else 1.0
	var damage = selected_tower.get("attack_damage") if selected_tower.has_method("get") else 25.0
	var range_val = selected_tower.get("attack_range") if selected_tower.has_method("get") else 150.0

	var speed_level = selected_tower.get("speed_upgrade_level") if selected_tower.has_method("get") else 0
	var damage_level = selected_tower.get("damage_upgrade_level") if selected_tower.has_method("get") else 0
	var range_level = selected_tower.get("range_upgrade_level") if selected_tower.has_method("get") else 0

	# 다음 레벨 값 계산
	var next_speed = speed * 1.2
	var next_damage = damage * 1.5
	var next_range = range_val * 1.2

	attack_speed_button.text = "⚡ 공격속도 업그레이드\n비용: %dG (Lv.%d)\n현재: %.1f -> %.1f" % [UPGRADE_COST_SPEED, speed_level, speed, next_speed]
	attack_damage_button.text = "💥 공격력 업그레이드\n비용: %dG (Lv.%d)\n현재: %.0f -> %.0f" % [UPGRADE_COST_DAMAGE, damage_level, damage, next_damage]
	range_button.text = "🎯 사정거리 업그레이드\n비용: %dG (Lv.%d)\n현재: %.0f -> %.0f" % [UPGRADE_COST_RANGE, range_level, range_val, next_range]

	# 판매 가격 표시
	var cost = selected_tower.get("cost") if selected_tower.has_method("get") else 100
	var sell_price = floori(cost * 0.7)
	sell_button.text = "💰 타워 판매 (%dG)" % sell_price

func _on_attack_speed_pressed() -> void:
	if is_instance_valid(selected_tower):
		upgrade_requested.emit(selected_tower, "speed")
		_update_button_info()

func _on_attack_damage_pressed() -> void:
	if is_instance_valid(selected_tower):
		upgrade_requested.emit(selected_tower, "damage")
		_update_button_info()

func _on_range_pressed() -> void:
	if is_instance_valid(selected_tower):
		upgrade_requested.emit(selected_tower, "range")
		_update_button_info()

func _on_sell_pressed() -> void:
	if is_instance_valid(selected_tower):
		print("판매 요청: ", selected_tower)
		sell_requested.emit(selected_tower)
	hide()
	selected_tower = null

func _on_close_pressed() -> void:
	hide()
	selected_tower = null

func _unhandled_input(event: InputEvent) -> void:
	# UI 바깥을 클릭하면 패널 숨김
	if event is InputEventMouseButton and event.pressed and visible:
		if container and not container.get_rect().has_point(container.get_local_mouse_position()):
			hide()
			selected_tower = null
