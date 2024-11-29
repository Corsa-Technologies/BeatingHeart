extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0

# Referências aos nodes
@onready var hitboxarea = $hitboxarea
@onready var ataquemelle = hitboxarea.get_node("ataquemelle")
@onready var spriteplayer = $spriteplayer  # Referência ao AnimatedSprite2D

# Controle da direção do player (-1 para esquerda, 1 para direita)
var facing_direction := 1
const HITBOX_OFFSET := 30  # Distância do hitbox em relação ao player

# Estado de ataque
var is_attacking := false

func _ready() -> void:
	# Inicia com o hitbox invisível e na posição inicial
	hitboxarea.visible = false
	update_hitbox_position()

func _physics_process(delta: float) -> void:
	# Gravidade e salto
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimentação
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and not is_attacking:
		velocity.x = direction * SPEED
		facing_direction = sign(direction)  # Atualiza a direção do player
		update_hitbox_position()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Ataque
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		hitboxarea.visible = true
		ataquemelle.play("ataque1")

	# Troca de "personagens" usando funções dedicadas
	if Input.is_action_just_pressed("neutro"):
		set_neutro()
	elif Input.is_action_just_pressed("felicidade"):
		set_felicidade()
	elif Input.is_action_just_pressed("tristeza"):
		set_tristeza()
	elif Input.is_action_just_pressed("raiva"):
		set_raiva()

func _on_ataquemelle_animation_finished() -> void:
	# Torna o hitbox invisível ao final da animação
	hitboxarea.visible = false
	is_attacking = false  # Permite que o player mude de lado novamente

func update_hitbox_position() -> void:
	# Ajusta o offset do hitbox com base na direção
	hitboxarea.position.x = HITBOX_OFFSET * facing_direction
	hitboxarea.scale.x = facing_direction  # Espelha o hitbox horizontalmente se necessário

# Funções dedicadas para trocar de "personagem"
func set_neutro() -> void:
	spriteplayer.play("neutro")
	print("Personagem alterado para Neutro.")
	# Adicione lógica extra aqui, se necessário

func set_felicidade() -> void:
	spriteplayer.play("felicidade")
	print("Personagem alterado para Felicidade.")
	# Adicione lógica extra aqui, se necessário

func set_tristeza() -> void:
	spriteplayer.play("tristeza")
	print("Personagem alterado para Tristeza.")
	# Adicione lógica extra aqui, se necessário

func set_raiva() -> void:
	spriteplayer.play("raiva")
	print("Personagem alterado para Raiva.")
	# Adicione lógica extra aqui, se necessário
