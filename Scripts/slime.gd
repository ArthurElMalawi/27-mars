extends CharacterBody2D

@export var speed = 80.0
@export var knockback_force = 400.0
@export var damage = 10
@export var contact_damage = 5
@export var stop_distance = 35.0
@export var attack_cooldown = 1.2

@onready var anim = $AnimatedSprite2D
@onready var detection_zone = $Area2D
@onready var hitbox = $HitboxArea
@onready var attack_zone = $AttackZone

var player = null
var last_direction = "down"
var can_deal_damage = true
var can_contact_damage = true
var is_hurt = false
var is_attacking = false
var hp = 100

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	# Contact direct - toujours actif
	hitbox.monitoring = true
	hitbox.body_entered.connect(_on_contact_player)
	# Attaque animée - désactivée par défaut
	attack_zone.monitoring = false
	attack_zone.body_entered.connect(_on_attack_player)

func _on_contact_player(body):
	if body.is_in_group("player") and can_contact_damage:
		can_contact_damage = false
		var knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(contact_damage, knockback_dir * knockback_force)
		await get_tree().create_timer(0.8).timeout
		can_contact_damage = true

func _on_attack_player(body):
	if body.is_in_group("player"):
		var knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_dir * knockback_force)
		attack_zone.monitoring = false

func _on_animation_finished():
	if is_attacking:
		is_attacking = false
		attack_zone.monitoring = false
		can_deal_damage = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_deal_damage = true

func _physics_process(_delta):
	if is_hurt:
		velocity = velocity.move_toward(Vector2.ZERO, 30)
		move_and_slide()
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	player = null
	for body in detection_zone.get_overlapping_bodies():
		if body.is_in_group("player"):
			player = body
			break

	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= stop_distance and can_deal_damage:
			_attack()
		elif distance > stop_distance:
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

func _attack():
	is_attacking = true
	velocity = Vector2.ZERO
	anim.play("attack_" + last_direction)
	await get_tree().create_timer(0.5).timeout
	attack_zone.monitoring = true

func _idle():
	anim.play("idle_" + last_direction)
	velocity = Vector2.ZERO
	move_and_slide()

func take_damage(amount, knockback):
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

func die():
	anim.play("death_" + last_direction)
	await anim.animation_finished
	queue_free()
