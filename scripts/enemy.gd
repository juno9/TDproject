extends PathFollow2D

# 적 캐릭터 - 경로를 따라 이동

signal died(gold_reward: int)
signal reached_end

@export var base_health: float = 100.0
@export var base_speed: float = 50.0
@export var gold_reward: int = 10

var current_max_health: float
var current_speed: float
var current_health: float
var is_alive: bool = true
var enemy_id: int = 0  # 디버깅용 ID

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	# 디버깅용 고유 ID 생성
	enemy_id = randi() % 1000

	# set_stats가 호출되지 않았을 경우를 대비한 기본값 설정
	if current_max_health == 0:
		set_stats(1)

	progress_ratio = 0.0
	update_health_bar()
	print("[적 #", enemy_id, "] 생성됨")

func _process(delta: float) -> void:
	if not is_alive:
		return

	# 경로를 따라 이동
	progress += current_speed * delta

	# 경로 끝에 도달 (0.95 이상이면 도달로 간주 - 부동소수점 오차 고려)
	if progress_ratio >= 0.95:
		print("[적 #", enemy_id, "] 라인 끝에 도달! progress_ratio: ", progress_ratio)
		print("[적 #", enemy_id, "] reached_end 시그널 발생")
		is_alive = false  # 중복 처리 방지
		reached_end.emit()
		queue_free()

# 웨이브에 따라 능력치 설정
func set_stats(wave: int) -> void:
	# 웨이브에 따라 체력과 속도 증가 (공식은 원하는 대로 조절 가능)
	current_max_health = base_health + (wave - 1) * 20.0
	current_speed = base_speed + (wave - 1) * 2.0
	
	current_health = current_max_health
	update_health_bar()

func take_damage(damage: float) -> void:
	if not is_alive:
		return

	current_health -= damage
	print("적 피해: ", damage, " (남은 HP: ", current_health, ")")
	update_health_bar()

	if current_health <= 0:
		die()

func die() -> void:
	if not is_alive:
		return

	print("[적 #", enemy_id, "] 사망! progress_ratio: ", progress_ratio)
	is_alive = false
	died.emit(gold_reward)

	# 사망 애니메이션 (간단하게 페이드아웃)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func update_health_bar() -> void:
	if health_bar:
		health_bar.max_value = current_max_health
		health_bar.value = current_health

func get_position_2d() -> Vector2:
	return global_position
