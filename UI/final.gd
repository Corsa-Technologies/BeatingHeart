extends Control

func _process(delta: float) -> void:
	# Verifica se a tecla espaço foi pressionada
	if Input.is_action_just_pressed("ui_espaco"):  # "ui_accept" mapeia a tecla espaço por padrão
		# Troca de cena se o texto já estiver visível
		get_tree().change_scene_to_file("res://UI/menu.tscn")
