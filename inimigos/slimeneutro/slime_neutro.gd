extends CharacterBody2D

const SPEED = 300.0
const GRAVITY = 1200.0  # Valor da gravidade
const MAX_FALL_SPEED = 1000.0  # Velocidade máxima de queda

# Referências
@onready var detection_area = $detecção
@onready var animation_player = $AnimatedSprite2D

# Variável para guardar a referência do player
var target_player: CharacterBody2D = null

func _ready() -> void:
	animation_player.play("idle")

func _physics_process(delta: float) -> void:
	# Aplicar gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)  # Limita a velocidade máxima de queda
	else:
		velocity.y = 0  # Para a gravidade quando no chão

	# Movimentação em direção ao player, se detectado
	if target_player:
		var direction = sign(target_player.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		animation_player.play("walk")
	else:
		velocity.x = 0
		animation_player.play("idle")

	# Movimenta o inimigo
	move_and_slide()

# Chamado quando o player entra na área de detecção
func _on_detecção_body_entered(body: Node) -> void:
	if body.name == "Personagem":  # Certifique-se de que o nome do player é "Personagem"
		target_player = body

# Chamado quando o player sai da área de detecção
func _on_detecção_body_exited(body: Node) -> void:
	if body == target_player:
		target_player = null
