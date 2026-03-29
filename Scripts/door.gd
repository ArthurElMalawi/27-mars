extends Area2D

@export_file("*.tscn") var next_room_path: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if next_room_path != "" and FileAccess.file_exists(next_room_path):
			get_tree().call_deferred("change_scene_to_file", next_room_path)
		else:
			print("Oups ! Tu as oublié de choisir la scène de destination dans l'inspecteur.")
