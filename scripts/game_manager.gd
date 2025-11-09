extends Node2D

# 게임 매니저 - 웨이브, 골드, 점수 관리

signal wave_completed
signal game_over

@export var starting_gold: int = 200
@export var starting_lives: int = 20
@export var wave_interval: float = 5.0

var current_gold: int = 0
var current_lives: int = 0
var current_wave: int = 0
var score: int = 0
var enemies_alive: int = 0
var is_spawning: bool = false

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var enemy_path: Path2D = $EnemyPath

# 적 프리팹 (씬에서 설정)
@export var enemy_scene: PackedScene

func _ready() -> void:
	current_gold = starting_gold
	current_lives = starting_lives

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)

	# UI 업데이트
	update_ui()

	# 첫 웨이브 시작 대기
	wave_timer.start(3.0)

func start_wave() -> void:
	if is_spawning:
		return

	current_wave += 1
	is_spawning = true

	var enemies_to_spawn = 5 + (current_wave * 2)
	var spawn_delay = max(0.5, 2.0 - (current_wave * 0.1))

	for i in range(enemies_to_spawn):
		await get_tree().create_timer(spawn_delay).timeout
		spawn_enemy()

	is_spawning = false

func spawn_enemy() -> void:
	if not enemy_scene:
		push_error("적 씬이 설정되지 않았습니다!")
		return

	var enemy = enemy_scene.instantiate()
	
	# *** 추가된 부분: 적 능력치를 현재 웨이브에 맞게 설정 ***
	if enemy.has_method("set_stats"):
		enemy.set_stats(current_wave)
	
	enemy_path.add_child(enemy)

	# 적 시그널 연결
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
		print("적의 died 시그널 연결됨")
	if enemy.has_signal("reached_end"):
		enemy.reached_end.connect(_on_enemy_reached_end)
		print("적의 reached_end 시그널 연결됨")
	else:
		print("ERROR: 적에 reached_end 시그널이 없습니다!")

	enemies_alive += 1

func _on_enemy_died(gold_reward: int) -> void:
	enemies_alive -= 1
	current_gold += gold_reward
	score += gold_reward * 10
	update_ui()
	check_wave_complete()

func _on_enemy_reached_end() -> void:
	print("적이 끝에 도달! 생명력 감소 전: ", current_lives)
	enemies_alive -= 1
	current_lives -= 1
	print("생명력 감소 후: ", current_lives)
	update_ui()

	if current_lives <= 0:
		game_over.emit()
		# 게임 오버 처리
		print("게임 오버! 최종 점수: ", score)

	check_wave_complete()

func check_wave_complete() -> void:
	if enemies_alive <= 0 and not is_spawning:
		wave_completed.emit()
		wave_timer.start(wave_interval)

func _on_wave_timer_timeout() -> void:
	start_wave()

func _on_spawn_timer_timeout() -> void:
	pass

func can_afford(cost: int) -> bool:
	return current_gold >= cost

func spend_gold(amount: int) -> bool:
	if can_afford(amount):
		current_gold -= amount
		update_ui()
		return true
	return false

func add_gold(amount: int) -> void:
	current_gold += amount
	update_ui()

func update_ui() -> void:
	# UI 업데이트 시그널 발생 또는 직접 UI 업데이트
	pass
