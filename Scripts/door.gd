extends Area2D

# On prépare la destination (tu choisiras le fichier dans l'inspecteur)
@export_file("*.tscn") var next_room_path: String

func _ready():
	# On connecte le signal de détection
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# On vérifie si c'est bien le joueur
	if body.name == "Player":
		if next_room_path != "" and FileAccess.file_exists(next_room_path):
			get_tree().change_scene_to_file(next_room_path)
		else:
			print("Oups ! Tu as oublié de choisir la scène de destination dans l'inspecteur.")
