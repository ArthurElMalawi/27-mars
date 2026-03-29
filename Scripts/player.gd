extends CharacterBody2D

@export var speed = 200.0
@export var run_speed = 400.0
@export var max_hp = 100
@export var attack_damage = 20

@onready var anim = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox

var current_hp = 100
var last_direction = "down"
var is_attacking = false
var attack_anim = ""
var is_hurt = false
var knockback_velocity = Vector2.ZERO

const ATTACK_CONFIG = {
	"down":  {"pos": Vector2(0, 20),  "rot": 0.0},
	"up":    {"pos": Vector2(0, -20), "rot": 0.0},
	"left":  {"pos": Vector2(-20, 0), "rot": PI / 2},
	"right": {"pos": Vector2(20, 0),  "rot": PI / 2}
}

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hit)

func _on_attack_hit(body):
	print("AttackHitbox touché : ", body.name)
	if body.is_in_group("enemy"):
		print("Dégâts envoyés à l'ennemi !")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(attack_damage, knockback_dir * 300)

func take_damage(amount, knockback):
	print("Joueur reçoit des dégâts !")
	if is_hurt:
		return
	current_hp -= amount
	knockback_velocity = knockback
	is_hurt = true
	anim.play("hurt_" + last_direction)

func _on_animation_finished():
	if is_attacking:
		is_attacking = false
		attack_anim = ""
		attack_hitbox.monitoring = false
	if is_hurt:
		is_hurt = false

func _physics_process(_delta):
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 30)
		move_and_slide()
		return

	if is_hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_running = Input.is_action_pressed("ui_shift")

	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"

	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		attack_hitbox.position = ATTACK_CONFIG[last_direction]["pos"]
		attack_hitbox.rotation = ATTACK_CONFIG[last_direction]["rot"]
		attack_hitbox.monitoring = true
		if direction != Vector2.ZERO and is_running:
			attack_anim = "run_attack_" + last_direction
		elif direction != Vector2.ZERO:
			attack_anim = "walk_attack_" + last_direction
		else:
			attack_anim = "attack_" + last_direction
		anim.play(attack_anim)

	if is_attacking:
		if attack_anim.begins_with("walk_attack") and direction != Vector2.ZERO:
			velocity = direction.normalized() * speed
		elif attack_anim.begins_with("run_attack") and direction != Vector2.ZERO:
			velocity = direction.normalized() * run_speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		return

	if direction != Vector2.ZERO:
		var anim_prefix = "run" if is_running else "walk"
		anim.play(anim_prefix + "_" + last_direction)
		velocity = direction.normalized() * (run_speed if is_running else speed)
	else:
		anim.play("idle_" + last_direction)
		velocity = Vector2.ZERO

	move_and_slide()
