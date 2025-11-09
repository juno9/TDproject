extends Node2D

# 발사체 - 타겟을 추적하여 데미지를 입힘

@export var speed: float = 300.0
@export var rotation_speed: float = 10.0

var target: Node2D = null
var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO

func initialize(new_target: Node2D, new_damage: float) -> void:
	target = new_target
	damage = new_damage

func _process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		queue_free()
		return

	# 타겟을 향해 이동
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

	global_position += velocity * delta

	# 회전
	rotation = velocity.angle()

	# 타겟과 충돌 체크
	if global_position.distance_to(target.global_position) < 10.0:
		hit_target()

func hit_target() -> void:
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		print("발사체 명중! 데미지: ", damage)
		target.take_damage(damage)

	# 발사체 제거
	queue_free()
