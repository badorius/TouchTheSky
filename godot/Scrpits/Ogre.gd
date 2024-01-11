extends CharacterBody2D

@export var speed = 50.0
#var AttackCount = 3
const DISTANCE_THRESHOLD = 75  # Distancia mínima para separarte del jugador
const DISTANCE_ATACK = 115
const JUMP_VELOCITY = -350.0
var state_machine
@export var state : String = "Iddle"
var target_position : Vector2
@export var timer : float = 0
@export var live : int = 1000
@export var ArrowDamage_sound : AudioStreamPlayer2D
@export var StartAttack_sound : AudioStreamPlayer2D
@export var HitAttack_sound : AudioStreamPlayer2D
@onready var player : CharacterBody2D = get_node("../Player")
@export var score_value : int = 100
@export var is_over_player : bool = false
@export var level_completed : bool = false
@export var Toxic : bool = false
var FreqToxic : float = 10.0
var FreqCounter : float = 0
const DamageIndicator = preload("../Objects/damage_indicator.tscn")

const FlayingEye = preload("../Objects/FlayingEye.tscn")
const Rock = preload("../Objects/Rock.tscn")
const Skeleton = preload("../Objects/skeleton.tscn")
const NightBorne = preload("../Objects/NightBorne.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$Sprite2D.visible = true
	$Explode.visible = false
	ArrowDamage_sound = $ArrowDamage
	StartAttack_sound = $StartAttack
	HitAttack_sound = $HitAttack
	state_machine = $AnimationTree.get('parameters/playback')
	#var player = get_parent().get_node("Player")



func _physics_process(delta):
	$ProgressBar.value = live/10
	if live <= 0:
		state = "Death"
		death()
		
	if Toxic == true:
		if FreqCounter < FreqToxic:
			FreqCounter += 0.1
		else:
			FreqCounter = 0
			hurt(5)
		
	#CHECK IS NOT OVER PLAYER 
	if abs(global_position.x - player.global_position.x) < DISTANCE_ATACK - 50:
		is_over_player = true
		set_scapeplayer()
	else:
		is_over_player = false
		
	if state != "Death":
		state = "ChasePlayer"
	
	
	#if abs(global_position.distance_to(player.global_position)) <= DISTANCE_THRESHOLD:
	#	set_jump()
		
	if abs(global_position.distance_to(player.global_position)) <= DISTANCE_ATACK:
		state = "Attack"
		
		
	if state == "ChasePlayer":
			$PointLight2D.enabled = true
	else:
			$PointLight2D.enabled = false
				
				
	match state:
		"Iddle":
			set_iddle()
		"ChasePlayer":
			set_chaseplayer()
		"Attack":
			set_attack()
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	
func set_iddle():
	state_machine.travel('Iddle')

func set_attack():
	var direction = (player.global_position - global_position).normalized()
	

	#Animation Attack and SET POSITION AREA ATACK
	if direction.x > 0:
		get_node( "Sprite2D" ).set_flip_h( false )
		$Sprite2D/Area2D.position.x = 0
		$ImpactEffect.position.x = 100
	else:
		get_node( "Sprite2D" ).set_flip_h( true )
		$Sprite2D/Area2D.position.x = -99
		$ImpactEffect.position.x = -100
	velocity.x = 0
	state_machine.travel('Attack')
	



		
func set_chaseplayer():
	var direction = (player.global_position - global_position).normalized()
	if direction.x > 0:
		get_node( "Sprite2D" ).set_flip_h( false )
		state_machine.travel('Run')
		velocity.x = direction.x * speed
	else:
		get_node( "Sprite2D" ).set_flip_h( true )
		state_machine.travel('Run')	
		velocity.x = direction.x  * speed
		
		
func set_scapeplayer():
	#speed = 200.0
	var direction = (player.global_position - global_position).normalized()
	if direction.x > 0:
		get_node( "Sprite2D" ).set_flip_h( false )
		state_machine.travel('Run')
		velocity.x = -abs(direction.x) * speed
	else:
		get_node( "Sprite2D" ).set_flip_h( true )
		state_machine.travel('Run')	
		velocity.x = +abs(direction.x) * speed
		
	#speed = 100.0


func set_jump():
	if is_on_floor():

		velocity.y = JUMP_VELOCITY
		var direction = (player.global_position - global_position).normalized()
		if direction.x > 0:
			get_node( "Sprite2D" ).set_flip_h( false )
			state_machine.travel('Run')
			velocity.x = -abs(direction.x) * speed
		else:
			get_node( "Sprite2D" ).set_flip_h( true )
			state_machine.travel('Run')	
			velocity.x = abs(direction.x) * speed
			state = "Jump"

	else:
		set_iddle()

			
func hurt(damage):
	live -= damage
	ArrowDamage_sound.play()
	$ProgressBar.value = live
	if live <= 0:
		state = "Death"
		death()
	else:
		state_machine.travel('Hurt')
		state = "Hurt"
	
	#FIX Random size
	var offset_position = randi() % 20
	var main = get_tree().current_scene
	var D = DamageIndicator.instantiate()
	var color = "yellow"
	D.global_position = Vector2(global_position.x - offset_position, (global_position.y) - offset_position)
	D.show_damage(damage, color)
	main.add_child(D)
	

func do_hurt():
	var attack_power = randi() % 100
	player.hurt(attack_power)
	

func drop_enemy():
	var main = get_tree().current_scene
	#Random enemy
	var EnemyRnd = randi() % 2
	
	var offset_position = randi() % 50
	var direction = (player.global_position - global_position).normalized()
	# Instatnce new enmies and Drop enemies
	
	match EnemyRnd:
		0:
			var EnemyDrop = Rock.instantiate()
			if direction.x > 1:
				EnemyDrop.global_position = Vector2(global_position.x*2  - offset_position , (global_position.y) - offset_position * 5)
			else:
				EnemyDrop.global_position = Vector2(global_position.x/2  - offset_position , (global_position.y) - offset_position * 5)
			main.add_child(EnemyDrop)
		1:
			var EnemyDrop = Skeleton.instantiate()
			if direction.x > 1:
				EnemyDrop.global_position = Vector2(global_position.x*2  - offset_position , (global_position.y) - offset_position * 5)
			else:
				EnemyDrop.global_position = Vector2(global_position.x/2  - offset_position , (global_position.y) - offset_position * 5)
			main.add_child(EnemyDrop)
		2:
			var EnemyDrop = NightBorne.instantiate()
			if direction.x > 1:
				EnemyDrop.global_position = Vector2(global_position.x*2  - offset_position , (global_position.y) - offset_position * 5)
			else:
				EnemyDrop.global_position = Vector2(global_position.x/2  - offset_position , (global_position.y) - offset_position * 5)
			main.add_child(EnemyDrop)	
		3:
			var EnemyDrop = FlayingEye.instantiate()
			if direction.x > 1:
				EnemyDrop.global_position = Vector2(global_position.x*2  - offset_position , (global_position.y) - offset_position * 5)
			else:
				EnemyDrop.global_position = Vector2(global_position.x/2  - offset_position , (global_position.y) - offset_position * 5)
			main.add_child(EnemyDrop)



func explode():
	pass
		
func death():
	$Sprite2D.visible = false
	$Explode.visible = true
	state_machine.travel('Death')
	player.add_score(score_value)
	level_completed = true
	#ADD ANIMATION TRESURE LIGHT AND NEXT LEVEL
	#get_tree().change_scene_to_file("res://Objects/Level2.tscn")


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		var attack_power = randi() % 100
		body.hurt(attack_power)
		
func decrease_speed(value):
	speed -= value

func toxic():
	Toxic = true
