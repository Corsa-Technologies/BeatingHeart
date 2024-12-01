extends CharacterBody2D

const SPEED = 300.0
const GRAVITY = 1200.0  # Valor da gravidade
const MAX_FALL_SPEED = 1400.0  # Velocidade máxima de queda
const DAMAGE = 1  # Quantidade de dano que o inimigo causa

# Referências
@onready var detection_area = $detecção
@onready var animation_player = $AnimatedSprite2D
@onready var hitbox = $hitbox  # Referência à área de dano do inimigo
@onready var damage_timer = $DamageTimer  # Timer para cooldown de dano e perseguição
@onready var heal_timer = $HealTimer  # Timer para gerenciar a cura periódica
@onready var health_bar: ProgressBar = $BarradeVida

# Variáveis de controle
var target_player: CharacterBody2D = null
var can_follow: bool = true  # Controle para determinar se o slime pode seguir o player
var can_damage: bool = true  # Controle para determinar se o slime pode causar dano
var health: int = 8  # Vida inicial do inimigo
var max_health: int = 8  # Vida máxima do inimigo

func _ready() -> void:
	animation_player.play("idle")
	heal_timer.start()  # Inicia o timer de cura
	health_bar.max_value = max_health  # Define o valor máximo da barra de vida
	health_bar.value = health  # Atualiza a barra de vida com a vida inicial
	health_bar.visible = false
	
func _physics_process(delta: float) -> void:
	# Aplicar gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)  # Limita a velocidade máxima de queda
	else:
		velocity.y = 0  # Para a gravidade quando no chão

	# Movimentação em direção ao player, se detectado e permitido
	if target_player and can_follow:
		var direction = sign(target_player.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction == -1
		animation_player.play("walk")
	else:
		velocity.x = 0
		animation_player.play("idle")

	# Movimenta o inimigo
	move_and_slide()

# Chamado quando o player entra na área de detecção
func _on_detecção_body_entered(body: Node):
	if body.name == "Personagem":  # Certifique-se de que o nome do player é "Personagem"
		target_player = body

# Chamado quando o player sai da área de detecção
func _on_detecção_body_exited(body: Node):
	if body == target_player:
		target_player = null

# Chamado quando o hitbox detecta o player
func _on_hitbox_body_entered(body: Node):
	if body.name == "Personagem" and body.has_method("take_damage") and can_damage:
		body.take_damage(DAMAGE)  # Causa dano no player
		_stop_following()  # Interrompe a perseguição temporariamente
		_start_damage_cooldown()  # Inicia cooldown para o próximo dano

# Função para parar de seguir o player
func _stop_following() -> void:
	can_follow = false
	damage_timer.start()  # Inicia o timer para voltar a seguir o player

# Função para iniciar cooldown de dano
func _start_damage_cooldown():
	can_damage = false
	damage_timer.start()  # Usa o mesmo timer para gerenciar o cooldown de dano

# Chamado quando o timer termina
func _on_damage_timer_timeout():
	can_follow = true  # Permite seguir o player novamente
	can_damage = true  # Permite causar dano novamente
	
func take_damage(player_damage: int):
	health -= player_damage
	health = clamp(health, 0, max_health)  # Garante que a vida não fique abaixo de 0 ou acima do máximo
	health_bar.value = health  # Atualiza a barra de vida
	health_bar.visible = true
	if health <= 0:
		die()
	
func die():
	queue_free()

# Função de cura periódica
func _on_heal_timer_timeout() -> void:
	if health < max_health:
		health += 2
		health = min(health, max_health)  # Garante que a vida não ultrapasse o máximo
		health_bar.value = health
