extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Personagem' and CharacterBody2D:  # Verifica se o objeto que entrou é o personagem
		body.global_position = Vector2(4846, 3245)  # Teleporta para o ponto (0, 0)
