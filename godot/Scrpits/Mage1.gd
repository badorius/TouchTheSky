extends CharacterBody2D

@export var speed = 100.0
var AttackCount = 3
const DISTANCE_THRESHOLD = 100  # Distancia mínima para perseguir al jugador
const DISTANCE_ATACK = 40
const JUMP_VELOCITY = -350.0
var state_machine
@export var state : String = "Iddle"
var target_position : Vector2
@export var timer : float = 0
@export var live : int = 1000000
@export var ArrowDamage_sound : AudioStreamPlayer2D
@onready var player : CharacterBody2D = get_node("../../Player")
@export var score_value : int = 50
@export var attack_power = randi() % 30
const DamageIndicator = preload("../Objects/Efects/damage_indicator.tscn")
const PointsIndicator = preload("res://Objects/Efects/points_indicator.tscn")
@export var pointsvalue : int = 1000
var startrun : bool = false
@export var Toxic : bool = false
@export var Ice : bool = false
var FreqToxic : float = 10.0
var FreqCounter : float = 0
@onready var ProgressBar3 : TextureProgressBar = get_node("ProgressBar/Control/TextureProgressBar") 
const Explode = preload("../Objects/Efects/EnemyExplode.tscn")

#Vars to Wave y movement
var bob_height : float = 100.0
var bob_speed : float = 5.0
@onready var start_y : float = global_position.y
var t : float = 0.0



func _ready():
	ArrowDamage_sound = $ArrowDamage
	state_machine = $AnimationTree.get('parameters/playback')
	$CollisionShape2D.disabled = false
	$".".modulate = "ffffff"

	
func _process(delta):
		if global_position.distance_to(player.global_position) < DISTANCE_THRESHOLD * 5 or state == "Hurt":
			startrun = true
			

			
func _physics_process(delta):
	
	if Toxic == true:
		$ToxicLight2D.color = "199f00e5"
		$ToxicLight2D.visible = true
		if FreqCounter < FreqToxic:
			FreqCounter += 0.1
		else:
			FreqCounter = 0
			hurt(50)
			
	if Ice == true:
		$IceLight2D.visible = true
	
	if startrun and state != "Death":
		ProgressBar3.value = live
		if live <= 0:
			death()


		get_node( "Sprite2D" ).set_flip_h( false )
		state_machine.travel('Run')	
		velocity.x = -speed
			# increase 't' over time.
		t += delta
		
		# creloopate a sin wave that bobs up and down.
		var d = (sin(t * bob_speed) + 1) / 2
		
		# apply that to  Y position.
		global_position.y = start_y + (d * bob_height)


	move_and_slide()
	

func hurt(damage):
	if live <= 0  and state != "Death":
		death()
	else:
		ArrowDamage_sound.play()
		#state_machine.travel('Hurt')
		#live -= damage
		speed = speed * 1.1
		bob_speed = bob_speed * 1.1
		#ProgressBar3.value = live
		state = "Hurt"



func do_hurt():
	attack_power = randi() % 30
	player.hurt(attack_power)

		
func explode():
		var main = get_tree().current_scene
		var A = Explode.instantiate()
		A.global_position = global_position
		main.add_child(A)
		
func death():
	#FIX Random size
	var offset_position = randi() % 20
	var main = get_tree().current_scene
	var D = PointsIndicator.instantiate()
	var color = "white"
	D.global_position = Vector2(global_position.x - offset_position, (global_position.y) - offset_position)
	D.show_points(pointsvalue, color)
	main.add_child(D)
		
	state = "Death"
	state_machine.travel('Death')
	explode()

func decrease_speed(value):
	if speed < 0:
		speed = 0
	else:
		speed -= value

func toxic():
	Toxic = true

func ice():
	Ice = true
	
