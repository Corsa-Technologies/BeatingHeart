extends CanvasLayer

# Referências aos corações
@onready var heart1 = $HBoxContainer/Heart1
@onready var heart2 = $HBoxContainer/Heart2
@onready var heart3 = $HBoxContainer/Heart3
@onready var heart4 = $HBoxContainer/Heart4
@onready var heart5 = $HBoxContainer/Heart5
@onready var heart6 = $HBoxContainer/Heart6
@onready var heart7 = $HBoxContainer/Heart7
@onready var heart8 = $HBoxContainer/Heart8
@onready var heart9 = $HBoxContainer/Heart9
@onready var heart10 = $HBoxContainer/Heart10

# Coração cheio e vazio
@export var full_heart_texture: Texture
@export var empty_heart_texture: Texture

func update_health_ui(current_health: int, max_health: int) -> void:
	# Lista de todos os corações
	var hearts = [heart1, heart2, heart3, heart4, heart5, heart6, heart7, heart8, heart9, heart10]
	
	# Garante que a quantidade de corações não ultrapasse o número disponível
	for i in range(min(max_health, hearts.size())):
		if i < current_health:
			hearts[i].texture = full_heart_texture  # Coração cheio
		else:
			hearts[i].texture = empty_heart_texture  # Coração vazio
