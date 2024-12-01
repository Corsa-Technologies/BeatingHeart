extends Control

@onready var texto: = $texto

func _ready() -> void:
	# Garante que o Texto comece invisível
	texto.visible = false

func _process(delta: float) -> void:
	# Verifica se a tecla espaço foi pressionada
	if Input.is_action_just_pressed("ui_espaco"):  # "ui_accept" mapeia a tecla espaço por padrão
		if not texto.visible:
			# Mostra o texto se estiver oculto
			texto.visible = true
		else:
			# Troca de cena se o texto já estiver visível
			get_tree().change_scene_to_file("res://Nivel/Nível 1/Nivel1.tscn")
