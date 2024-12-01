extends CharacterBody2D
@onready var animation_player = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $BarradeVida
@onready var timer: Timer = $Timer

var max_health: int = 30  # Vida máxima do inimigo
var health: int = max_health  # Vida inicial do inimigo
var is_hurt: bool = false  # Flag para controlar se o inimigo está em estado de "hurt"
var death_timer_started: bool = false  # Flag para evitar múltiplas execuções

func _ready() -> void:
	animation_player.play("beating")
	health_bar.max_value = max_health  # Define o valor máximo da barra de vida
	health_bar.value = health  # Atualiza a barra de vida com a vida inicial
	health_bar.visible = false

# Chamado a cada frame
func _process(delta: float) -> void:
	if not is_hurt and health > 0:
		animation_player.play("beating")

# Chamado quando o inimigo toma dano
func take_damage(player_damage: int) -> void:
	if health <= 0 or is_hurt:
		return  # Não permite dano adicional após a morte ou enquanto está ferido
	
	is_hurt = true
	animation_player.play("hurt")
	health -= player_damage
	health = clamp(health, 0, max_health)  # Garante que a vida não fique abaixo de 0 ou acima do máximo
	health_bar.value = health  # Atualiza a barra de vida
	health_bar.visible = true

	# Inicia o timer para retornar ao estado normal após curto período
	timer.start(0.5)

	if health <= 0:
		await die()

# Chamado quando o inimigo morre
func die() -> void:
	if death_timer_started:
		return  # Evita chamar die novamente
	
	death_timer_started = true
	animation_player.play("dead")
	health_bar.visible = false

	# Aguarda 4 segundos antes de trocar de cena
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://UI/final.tscn")  # Substitua pelo caminho correto
