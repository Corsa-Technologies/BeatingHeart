extends CharacterBody2D

const BASE_SPEED = 400.0
const JUMP_VELOCITY = -400.0

# Estados emocionais
enum Emotions { NEUTRO, FELICIDADE, TRISTEZA, RAIVA }
var current_emotion: int = Emotions.NEUTRO

# Variáveis para atributos de cada emoção
var player_health: int = 10  # Vida do jogador (agora 10 corações)
var max_health: int = 10     # Vida máxima (10 corações)
var player_damage: int = 1    # Dano do jogador
var player_speed: float = BASE_SPEED  # Velocidade do jogador

# Referências aos nodes
@onready var spriteplayer = $spriteplayer
@onready var hitboxarea = $hitboxarea
@onready var ataquemelle = hitboxarea.get_node("ataquemelle")
@onready var health_ui = $PlayerUI
@onready var life_regeneration_timer = $life_regeneration_timer  # Timer para regeneração
# Controle da direção do player (-1 para esquerda, 1 para direita)
var facing_direction := 1
const HITBOX_OFFSET := 30  # Distância do hitbox em relação ao player
# Estado de ataque
var is_attacking := false

# Variável para controle de inimigos já atingidos
var enemy_hit = false

func _ready() -> void:
	# Configurações iniciais
	hitboxarea.visible = false
	update_hitbox_position()
	update_emotion_animation("idle")
	life_regeneration_timer.start(1.0)
	health_ui.update_health_ui(player_health, max_health)

func _physics_process(delta: float) -> void:
	# Gravidade e salto
	if current_emotion == Emotions.TRISTEZA:
		# Permitir apenas a gravidade afetar a descida
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.y = 0  # Para de aplicar a gravidade ao atingir o chão
	else:
		# Lógica de gravidade e salto para outros estados emocionais
		if not is_on_floor():
			velocity += get_gravity() * delta
			if velocity.y > 0:
				update_emotion_animation("fall")
			else:
				update_emotion_animation("jump")
		else:
			if Input.is_action_just_pressed("ui_up"):
				velocity.y = JUMP_VELOCITY
				update_emotion_animation("jump")

	# Movimentação (somente se não estiver triste)
	if current_emotion != Emotions.TRISTEZA:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction and not is_attacking:
			velocity.x = direction * player_speed
			facing_direction = sign(direction)  # Atualiza a direção do player
			update_hitbox_position()
			update_emotion_animation("walk")
			
			# Atualiza a direção do sprite para o lado correto
			spriteplayer.flip_h = facing_direction == -1  # Espelha o sprite horizontalmente
		else:
			velocity.x = move_toward(velocity.x, 0, player_speed)
			if is_on_floor() and not is_attacking:
				update_emotion_animation("idle")
	elif current_emotion == Emotions.TRISTEZA:
		velocity.x = 0  # Bloqueia o movimento horizontal ao entrar em tristeza
		if is_on_floor() and not is_attacking:
			update_emotion_animation("idle")

	move_and_slide()

	# Ataque (somente se não for felicidade ou tristeza)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		if current_emotion != Emotions.FELICIDADE and current_emotion != Emotions.TRISTEZA:
			is_attacking = true
			hitboxarea.visible = true
			ataquemelle.play("ataque1")
			update_emotion_animation("attack")

	# Verificar se o inimigo já está na hitbox durante o ataque
	if is_attacking:
		check_hitbox_collision()

	# Troca de emoções
	if Input.is_action_just_pressed("neutro"):
		set_emotion(Emotions.NEUTRO)
	elif Input.is_action_just_pressed("raiva"):
		set_emotion(Emotions.RAIVA)
	elif Input.is_action_just_pressed("tristeza"):
		set_emotion(Emotions.TRISTEZA)
	elif Input.is_action_just_pressed("felicidade"):
		set_emotion(Emotions.FELICIDADE)

# Verifica colisões na hitbox durante o ataque
func check_hitbox_collision():
	for body in hitboxarea.get_overlapping_bodies():
		if body.name != "Personagem" and body.has_method("take_damage") and not enemy_hit:
			body.take_damage(player_damage)
			enemy_hit = true  # Marca que o inimigo foi atingido

# Método para finalizar o ataque
func _on_ataquemelle_animation_finished() -> void:
	# Torna o hitbox invisível ao final da animação
	hitboxarea.visible = false
	is_attacking = false
	enemy_hit = false  # Reseta o controle de inimigo atingido
	update_emotion_animation("idle")

func update_hitbox_position() -> void:
	# Ajusta o offset do hitbox com base na direção
	hitboxarea.position.x = HITBOX_OFFSET * facing_direction
	hitboxarea.scale.x = facing_direction  # Espelha o hitbox horizontalmente se necessário

# Troca de estado emocional
func set_emotion(emotion: int) -> void:
	current_emotion = emotion
	match emotion:
		Emotions.NEUTRO:
			player_damage = 1
			player_speed = BASE_SPEED
			print("Mudou para Neutro")
		Emotions.FELICIDADE:
			player_damage = 0     # Menos dano
			player_speed = BASE_SPEED * 2.0  # Mais velocidade
			print("Mudou para Felicidade")
		Emotions.TRISTEZA:
			player_speed = 0  # Sem movimento
			print("Mudou para Tristeza")
		Emotions.RAIVA:
			player_damage = 3    # Mais dano
			player_speed = BASE_SPEED * 0.2  # Velocidade reduzida
			print("Mudou para Raiva")
	# Atualiza a animação e a UI
	health_ui.update_health_ui(player_health, max_health)
	update_emotion_animation("idle")

# Atualiza a animação baseada no estado emocional e ação atual
func update_emotion_animation(action: String) -> void:
	if is_attacking and action != "attack":
		return  # Não troca a animação se estiver atacando
	
	var emotion_name = ""
	match current_emotion:
		Emotions.NEUTRO:
			emotion_name = "neutro"
		Emotions.FELICIDADE:
			emotion_name = "felicidade"
		Emotions.TRISTEZA:
			emotion_name = "tristeza"
		Emotions.RAIVA:
			emotion_name = "raiva"
	
	var animation_name = emotion_name + "_" + action
	if spriteplayer.animation != animation_name:  # Corrigido o uso de 'current_animation'
		spriteplayer.play(animation_name)

func _on_life_regeneration_timer_timeout() -> void:
	if current_emotion == Emotions.TRISTEZA and player_health < max_health:
		player_health += 1
		health_ui.update_health_ui(player_health, max_health)

# Função de dano
func take_damage(amount: int) -> void:
	player_health -= amount
	health_ui.update_health_ui(player_health, max_health)
	if player_health <= 0:
		die()  # Lógica de morte
		
func die():
	print('morri')


func _on_hitboxarea_body_entered(body: Node2D) -> void:
	if is_attacking and body.name == "SlimeNeutro" and body.has_method("take_damage"):
		print(body.name)
		print('achei o inimigo')
		body.take_damage(player_damage)  # Causa dano baseado na variável `player_damage
