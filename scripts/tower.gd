extends Node2D

# 타워 - 적을 탐지하고 공격

signal clicked(tower)

@export var attack_range: float = 150.0
@export var attack_damage: float = 25.0
@export var attack_speed: float = 1.0  # 초당 공격 횟수
@export var projectile_scene: PackedScene

# 업그레이드 및 비용 관련 변수
var cost: int = 100
var level: int = 1
var upgrade_cost: int = 75
var max_level: int = 5

var current_target: Node2D = null
var can_attack: bool = true
var enemies_in_range: Array[Node2D] = []
var is_preview: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var range_area: Area2D = $RangeArea
@onready var range_collision: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var range_indicator: Line2D = $RangeIndicator
@onready var click_area: Area2D = $ClickArea # 씬에 추가해야 할 Area2D

func _ready() -> void:
	update_stats_by_level()
	
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	range_area.area_entered.connect(_on_area_entered_range)
	range_area.area_exited.connect(_on_area_exited_range)
	click_area.input_event.connect(_on_input_event)

	draw_range_indicator()
	if not is_preview:
		range_indicator.visible = false

func set_initial_cost(initial_cost: int) -> void:
	cost = initial_cost
	# 초기 업그레이드 비용 등을 설정할 수 있음
	upgrade_cost = floori(cost * 0.75)

func update_stats_by_level() -> void:
	# 레벨에 따라 능력치 업데이트
	var damage_increase = 1.5
	var speed_increase = 1.2
	
	attack_damage = 25.0 * pow(damage_increase, level - 1)
	attack_speed = 1.0 * pow(speed_increase, level - 1)
	
	# 타이머, 사거리 등 업데이트
	attack_timer.wait_time = 1.0 / attack_speed
	if range_collision.shape is CircleShape2D:
		range_collision.shape.radius = attack_range

func draw_range_indicator() -> void:
	if not range_indicator: return
	var points = PackedVector2Array()
	var num_points = 64
	for i in range(num_points + 1):
		var angle = (i / float(num_points)) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * attack_range)
	range_indicator.points = points
	range_indicator.width = 2.0
	range_indicator.default_color = Color(0.3, 0.5, 1, 0.6)

func set_preview_mode(preview: bool) -> void:
	is_preview = preview
	if range_indicator: range_indicator.visible = preview
	if is_preview and attack_timer: attack_timer.stop()
	if click_area: click_area.input_pickable = not preview
	modulate = Color(1, 1, 1, 0.7) if is_preview else Color(1, 1, 1, 1)

func _process(_delta: float) -> void:
	if is_preview: return
	if not is_instance_valid(current_target) or not current_target.is_alive:
		find_new_target()
	if current_target:
		rotation = (current_target.global_position - global_position).angle()

func find_new_target() -> void:
	current_target = null
	var closest_dist = INF
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				current_target = enemy
	if current_target and attack_timer.is_stopped():
		attack_timer.start()

func _on_area_entered_range(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemy"):
		var enemy = area.get_parent()
		enemies_in_range.append(enemy)
		if not current_target: find_new_target()

func _on_area_exited_range(area: Area2D) -> void:
	var enemy = area.get_parent()
	enemies_in_range.erase(enemy)
	if enemy == current_target: find_new_target()

func _on_attack_timer_timeout() -> void:
	if is_instance_valid(current_target):
		attack(current_target)
	else:
		attack_timer.stop()

func attack(target: Node2D) -> void:
	if is_preview or not can_attack or not target: return
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_tree().root.add_child(projectile)
		projectile.global_position = global_position
		projectile.initialize(target, attack_damage)
	else:
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if is_preview: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("타워 input_event 감지됨!")
		clicked.emit(self)

# --- 업그레이드 및 판매 기능 ---

func can_upgrade() -> bool:
	return level < max_level

func upgrade() -> void:
	if not can_upgrade():
		return
	level += 1
	cost += upgrade_cost
	upgrade_cost = floori(upgrade_cost * 1.5) # 다음 업그레이드 비용 증가
	update_stats_by_level()
	# 레벨업 이펙트 등을 여기에 추가 가능

func sell() -> void:
	var refund = floori(cost * 0.7)
	var game_manager = get_tree().root.get_node("Main/GameManager") # 경로 확인 필요
	if game_manager:
		game_manager.add_gold(refund)
	print("타워 판매. %d 골드 환불." % refund)
	queue_free()
