extends Area2D


@export var damage: int = 2  # Valor do dano que será causado
func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name==("Personagem"):  # Verifica se o corpo é o jogador
		print('achei o player')
		# Chama a função take_damage do jogador
		body.take_damage(damage)
