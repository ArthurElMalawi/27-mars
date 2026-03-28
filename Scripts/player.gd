extends CharacterBody2D

@export var speed = 200.0
@export var run_speed = 400.0

@onready var anim = $AnimatedSprite2D

var last_direction = "down"
var is_attacking = false
var attack_anim = ""  # On stocke l'anim d'attaque en cours

func _ready():
	anim.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if is_attacking:
		is_attacking = false
		attack_anim = ""

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_running = Input.is_action_pressed("ui_shift")

	# Mettre à jour la direction AVANT de gérer l'attaque
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"

	# Déclenchement de l'attaque
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true

		if direction != Vector2.ZERO and is_running:
			attack_anim = "run_attack_" + last_direction
		elif direction != Vector2.ZERO:
			attack_anim = "walk_attack_" + last_direction
		else:
			attack_anim = "attack_" + last_direction

		anim.play(attack_anim)

	# Pendant l'attaque
	if is_attacking:
		# walk_attack et run_attack : le perso continue de bouger
		if attack_anim.begins_with("walk_attack") and direction != Vector2.ZERO:
			velocity = direction.normalized() * speed
		elif attack_anim.begins_with("run_attack") and direction != Vector2.ZERO:
			velocity = direction.normalized() * run_speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		return

	# Mouvement normal
	if direction != Vector2.ZERO:
		var anim_prefix = "run" if is_running else "walk"
		anim.play(anim_prefix + "_" + last_direction)
		velocity = direction.normalized() * (run_speed if is_running else speed)
	else:
		anim.play("idle_" + last_direction)
		velocity = Vector2.ZERO

	move_and_slide()
