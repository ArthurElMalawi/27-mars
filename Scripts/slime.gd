extends CharacterBody2D

@export var speed = 80.0
@export var knockback_force = 400.0
@export var damage = 10
@export var stop_distance = 30.0

@onready var anim = $AnimatedSprite2D
@onready var detection_zone = $Area2D
@onready var hitbox = $HitboxArea

var player = null
var last_direction = "down"
var can_deal_damage = true
var is_hurt = false
var hp = 50


func _ready():
	hitbox.body_entered.connect(_on_hit_player)

func _on_hit_player(body):
	print("HitboxArea touché par : ", body.name)
	if body.is_in_group("player") and can_deal_damage:
		print("Dégâts envoyés au joueur !")
		can_deal_damage = false
		var knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_dir * knockback_force)
		await get_tree().create_timer(1.0).timeout
		can_deal_damage = true

func take_damage(amount, knockback):
	print("Slime reçoit des dégâts !")
	if is_hurt:
		return
	hp -= amount
	is_hurt = true
	velocity = knockback
	anim.play("hurt_" + last_direction)
	await get_tree().create_timer(0.5).timeout
	is_hurt = false
	if hp <= 0:
		die()

func _physics_process(_delta):
	# Bloque tout pendant hurt
	if is_hurt:
		velocity = velocity.move_toward(Vector2.ZERO, 30)
		move_and_slide()
		return

	player = null
	for body in detection_zone.get_overlapping_bodies():
		if body.is_in_group("player"):
			player = body
			break

	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance > stop_distance:
			_chase_player()
		else:
			_idle()
	else:
		_idle()

func _chase_player():
	var direction = (player.global_position - global_position).normalized()
	if abs(direction.x) > abs(direction.y):
		last_direction = "right" if direction.x > 0 else "left"
	else:
		last_direction = "down" if direction.y > 0 else "up"
	anim.play("walk_" + last_direction)
	velocity = direction * speed
	move_and_slide()

func _idle():
	anim.play("idle_" + last_direction)
	velocity = Vector2.ZERO
	move_and_slide()

func die():
	anim.play("death_" + last_direction)
	await anim.animation_finished
	queue_free()
