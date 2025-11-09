extends Node2D

# 타워 배치 시스템

signal tower_placed(tower: Node2D)

@export var tower_scene: PackedScene
@export var tower_cost: int = 100 # tower.gd의 기본값과 일치시킴

var is_placing_tower: bool = false
var preview_tower: Node2D = null
var game_manager: Node = null

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

func _input(event: InputEvent) -> void:
	if not is_placing_tower:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		place_tower()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_placement()

func place_tower() -> void:
	if not is_placing_tower or not preview_tower:
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
