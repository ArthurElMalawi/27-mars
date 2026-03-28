extends CharacterBody2D

@export var speed = 400.0  # Tu pourras changer la vitesse dans l'inspecteur !

func _physics_process(_delta):
	# On récupère la direction (Z/Q/S/D ou Flèches par défaut dans Godot)
	# "ui_left", etc. sont les touches de base configurées par Godot.
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si on bouge, on applique la vitesse
	if direction:
		velocity = direction * speed
	else:
		# Sinon, on s'arrête (freinage immédiat pour un feeling nerveux)
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	# move_and_slide gère les collisions et utilise la variable 'velocity'
	move_and_slide()
