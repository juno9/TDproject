extends Node2D

# 타워 배치 시스템

signal tower_placed(tower: Node2D)

@export var tower_scene: PackedScene
@export var tower_cost: int = 100 # tower.gd의 기본값과 일치시킴
@export var tower_radius: float = 30.0 # 타워의 충돌 반경

var is_placing_tower: bool = false
var preview_tower: Node2D = null
var game_manager: Node = null
var can_place: bool = true # 현재 위치에 배치 가능한지 여부

func _ready() -> void:
	pass

func set_game_manager(manager: Node) -> void:
	game_manager = manager

func start_placing_tower() -> void:
	if is_placing_tower:
		return

	if not game_manager or not game_manager.can_afford(tower_cost):
		print("골드가 부족합니다!")
		return

	is_placing_tower = true

	if tower_scene:
		preview_tower = tower_scene.instantiate()
		add_child(preview_tower)
		if preview_tower.has_method("set_preview_mode"):
			preview_tower.set_preview_mode(true)
		print("타워 배치 모드 시작 - 좌클릭: 배치, 우클릭: 취소")

func _process(_delta: float) -> void:
	if is_placing_tower and preview_tower:
		preview_tower.global_position = get_global_mouse_position()

		# 배치 가능 여부 체크
		can_place = check_placement_valid(preview_tower.global_position)

		# 프리뷰 색상 업데이트
		update_preview_color()

func _input(event: InputEvent) -> void:
	if not is_placing_tower:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		place_tower()
		# 이벤트를 소비하여 다른 노드(타워)로 전달되지 않게 함
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_placement()
		# 이벤트를 소비하여 다른 노드로 전달되지 않게 함
		get_viewport().set_input_as_handled()

func place_tower() -> void:
	if not is_placing_tower or not preview_tower:
		return

	# 배치 불가능한 위치인 경우
	if not can_place:
		print("이 위치에는 타워를 배치할 수 없습니다!")
		return

	if game_manager and game_manager.spend_gold(tower_cost):
		var tower = tower_scene.instantiate()
		# 타워를 Game Manager나 다른 노드 아래에 두어 관리 용이하게 할 수 있음
		get_tree().root.get_node("Main").add_child(tower)
		tower.global_position = get_global_mouse_position()

		if tower.has_method("set_initial_cost"):
			tower.set_initial_cost(tower_cost)
		if tower.has_method("set_preview_mode"):
			tower.set_preview_mode(false)

		tower_placed.emit(tower)
		print("타워 배치됨 (골드 -%d)" % tower_cost)
	else:
		print("골드가 부족합니다!")

	if preview_tower:
		preview_tower.queue_free()
		preview_tower = null
	is_placing_tower = false

func cancel_placement() -> void:
	if preview_tower:
		preview_tower.queue_free()
		preview_tower = null
	is_placing_tower = false
	print("타워 배치 취소")

# 배치 가능 여부 체크
func check_placement_valid(pos: Vector2) -> bool:
	# 경로와 충돌 체크
	if is_overlapping_path(pos):
		return false

	# 다른 타워와 충돌 체크
	if is_overlapping_tower(pos):
		return false

	return true

# 경로와 겹치는지 체크
func is_overlapping_path(pos: Vector2) -> bool:
	if not game_manager:
		return false

	var enemy_path = game_manager.get_node_or_null("EnemyPath")
	if not enemy_path or not enemy_path is Path2D:
		return false

	var curve = enemy_path.curve
	if not curve:
		return false

	# 경로의 각 지점을 체크
	var path_width = 40.0 # Line2D의 width와 일치
	# Path2D의 scale을 고려하여 실제 너비 계산
	var actual_path_width = path_width * enemy_path.scale.x
	var check_distance = actual_path_width / 2.0 + tower_radius

	for i in range(curve.point_count):
		# transform을 적용하여 실제 글로벌 위치 계산 (position, rotation, scale 모두 반영)
		var point_pos = enemy_path.to_global(curve.get_point_position(i))
		if pos.distance_to(point_pos) < check_distance:
			return true

		# 각 세그먼트에 대해 더 세밀하게 체크
		if i < curve.point_count - 1:
			var next_point_pos = enemy_path.to_global(curve.get_point_position(i + 1))
			# 선분과 원의 충돌 체크
			if is_circle_intersecting_line(pos, tower_radius + actual_path_width / 2.0, point_pos, next_point_pos):
				return true

	return false

# 원과 선분의 충돌 체크
func is_circle_intersecting_line(circle_pos: Vector2, radius: float, line_start: Vector2, line_end: Vector2) -> bool:
	var line_vec = line_end - line_start
	var circle_vec = circle_pos - line_start
	var line_len = line_vec.length()

	if line_len == 0:
		return circle_pos.distance_to(line_start) < radius

	var t = clampf(circle_vec.dot(line_vec) / (line_len * line_len), 0.0, 1.0)
	var closest_point = line_start + line_vec * t
	return circle_pos.distance_to(closest_point) < radius

# 다른 타워와 겹치는지 체크
func is_overlapping_tower(pos: Vector2) -> bool:
	var main_node = get_tree().root.get_node_or_null("Main")
	if not main_node:
		return false

	# Main 노드의 모든 자식 중 타워 찾기
	for child in main_node.get_children():
		# 타워인지 확인 (attack_range 속성이 있으면 타워로 간주)
		if child != preview_tower and child.has_method("attack") and child.is_inside_tree():
			var distance = pos.distance_to(child.global_position)
			if distance < tower_radius * 2: # 타워끼리의 최소 거리
				return true

	return false

# 프리뷰 색상 업데이트
func update_preview_color() -> void:
	if not preview_tower:
		return

	if can_place:
		# 배치 가능 - 파란색
		preview_tower.modulate = Color(0.5, 0.5, 1.0, 0.7)
	else:
		# 배치 불가 - 빨간색
		preview_tower.modulate = Color(1.0, 0.3, 0.3, 0.7)
