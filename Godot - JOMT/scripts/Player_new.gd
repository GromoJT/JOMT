extends StairsCharacter

# Player nodes
@onready var head = $nek/Head
@onready var nek = $nek

@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var camera_3d = $nek/Head/eyes/Camera3D
@onready var gun_cam: Camera3D = $nek/Head/eyes/Camera3D/SubViewportContainer/SubViewport/GunCam
@onready var eyes = $nek/Head/eyes
@onready var animation_player = $nek/Head/eyes/AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $PlayerAudio/AudioStreamPlayer

@onready var interaction_grabing = $nek/Head/eyes/Camera3D/Interaction_grabing
@onready var hand = $nek/Head/eyes/Camera3D/Hand
@onready var joint = $nek/Head/eyes/Camera3D/Generic6DOFJoint3D
@onready var static_body = $nek/Head/eyes/Camera3D/StaticBody3D
@onready var grab_delay = $Grab_delay
@onready var talk_timer: Timer = $Talk_timer

@onready var throw_pos = $nek/Head/eyes/Camera3D/Throw_pos
@onready var drop_check: Area3D = $nek/Head/eyes/Camera3D/Drop_check
@onready var dd_check: RayCast3D = $nek/Head/eyes/Camera3D/dd_check

@onready var ui: CanvasLayer = $UI_controller/UI

@onready var pouse_menu: Control = $Game_UI/PouseMenu


# external nodes
var sound_direct = preload("res://audio/sound_direct.tscn")

@export var footsteps_sounds : Array[AudioStreamMP3]

var can_play_stpe_left: bool = true
var can_play_stpe_right: bool = true

# Speed vars
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
@export var slide_speed = 10.0

# States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var slideable = false
var leaning = false
var locked_look = false
var can_grab = true
var in_dialoge = false
var moon_walk = false

var poused = false

# Slide vars

var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO

# Head bobbing vars

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_intensity = 0.25
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05
var head_bobbing_current_intensity = 0.0

var head_bobing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

# Player atributes
@export var player_height = 1.8
@export var mouse_sens = 0.25

# semi CONSTS
var current_speed = 5.0
const JUMP_VELOCITY = 4.5

# crouch settings
var lerp_speed = 15.0
var air_lerp_speed = 1.5
var crouching_depth = -0.9

# leaning settings
var lean_pos_x = 0.46
var lean_pos_y = player_height - 0.15
var lean_rot_z = deg_to_rad(15)

var free_look_tilt_amount = 5

var last_velocity = Vector3.ZERO

# Global vars
var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# grab interaction
var picked_object
var pull_power = 10
var rotation_power = 2
var can_drop = true
@onready var sub_viewport: SubViewport = $nek/Head/eyes/Camera3D/SubViewportContainer/SubViewport

#	Start
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.itsOver.connect(_on_dialogue_ended)
	super()

func _on_dialogue_ended():
	print("Ehcho")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	talk_timer.start()
#	Input(event)
func _input(event):
	if event is InputEventMouseMotion and !in_dialoge:
#		print("RUCH")
		if !locked_look:
			if free_looking:
				nek.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
				nek.rotation.y = clamp(nek.rotation.y,deg_to_rad(-140),deg_to_rad(140))
			else:
				rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
			if picked_object != null:
				picked_object.rotate_x(deg_to_rad(event.relative.x * mouse_sens))
		else:
			rotate_object(event)

func _process(delta: float) -> void:
	gun_cam.global_transform = camera_3d.global_transform
	drop_check.global_transform = hand.global_transform

func pouseMenu():
	if poused:
		pouse_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Engine.time_scale = 1
	else:
		pouse_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Engine.time_scale = 0
	poused = !poused


func _physics_process(delta):
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	if input_dir.x<0 and input_dir.y>0 or input_dir.x==0 and input_dir.y==1 or input_dir.x>0 and input_dir.y>0:
		moon_walk = true
	else:
		moon_walk = false
	#	Wyjście z gry
	if Input.is_action_just_pressed("esc"):
		pouseMenu()
		
	if Input.is_action_just_pressed("interact") and !in_dialoge:
		try_interact()
	# Handle pikingfings up
	if Input.is_action_pressed("interact"):
		if can_grab:
			pick_object()
			if Input.is_action_just_pressed("interact_2"):
				if picked_object != null:
					if can_drop:
						if dd_check.get_collider() == null:
							joint.set_node_b(joint.get_path())
							picked_object.global_position = throw_pos.global_position
							var knokback = picked_object.global_position - eyes.global_position
							picked_object.apply_central_impulse(knokback * 20)
						remove_object()
			if Input.is_action_pressed("free_look"):
				locked_look = true
			else:
				locked_look = false
	if Input.is_action_just_released("interact"):
		locked_look = false
		if can_drop:
			if dd_check.get_collider() == null:
				remove_object()
	if picked_object != null:
		if !Input.is_action_pressed("interact"):
			locked_look = false
			if can_drop:
				if dd_check.get_collider() == null:
					remove_object()
				else:
					print("nope")
	if picked_object != null:
#		print(rad_to_deg(head.rotation.x))
		if rad_to_deg(head.rotation.x) < -40:
			hand.position = Vector3(0.6,-0.5,-0.8)
		else:
			hand.position = Vector3(0,-0.5,-1.3)
			
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a) * pull_power)
	#	Kucanie
	if Input.is_action_pressed("crouch") || sliding and !in_dialoge:
		current_speed = lerp(current_speed,crouching_speed,delta * lerp_speed)
		head.position.y = lerp(head.position.y,crouching_depth,delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		if sprinting and input_dir != Vector2.ZERO and is_on_floor() and slideable and !moon_walk:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		
		walking = false
		sprinting = false
		crouching = true
	
	#	koniec kucania
	elif !ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y,0.0,delta * lerp_speed)
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		#	Sprint
		if Input.is_action_pressed("sprint") and !moon_walk:
			current_speed = lerp(current_speed,sprinting_speed,delta * (lerp_speed/3))
			if current_speed > 7.5:
				slideable = true;
			else:
				slideable = false;
			walking = false
			sprinting = true
			crouching = false
			
		else:
			current_speed = lerp(current_speed,walking_speed,delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
	
	# Handle freelooking
	if Input.is_action_pressed("free_look") || sliding and picked_object==null:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z,-deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(nek.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		nek.rotation.y = lerp(nek.rotation.y,deg_to_rad(0.0),delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z,deg_to_rad(0.0),delta * lerp_speed)
	
	# Handle Leaning
	if Input.is_action_pressed("leanL") or Input.is_action_pressed("leanR") and !sliding and !in_dialoge:
		leaning = true;
		walking_speed = 2.0
		if Input.is_action_pressed("leanL"): 
			nek.position.x = lerp(nek.position.x, -lean_pos_x, delta * lerp_speed/3)
			nek.position.y = lerp(nek.position.y, lean_pos_y, delta * lerp_speed/3)
			nek.rotation.z = lerp(nek.rotation.z,lean_rot_z,delta * lerp_speed/3)
			
		if Input.is_action_pressed("leanR"):
			nek.position.x = lerp(nek.position.x, lean_pos_x, delta * lerp_speed/3)
			nek.position.y = lerp(nek.position.y, lean_pos_y, delta * lerp_speed/3)
			nek.rotation.z = lerp(nek.rotation.z,-lean_rot_z,delta * lerp_speed/3)
	else:
		leaning = false;
		walking_speed = 5.0
		nek.position.x = lerp(nek.position.x, 0.0, delta * lerp_speed)
		nek.position.y = lerp(nek.position.y, player_height, delta * lerp_speed)
		nek.rotation.z = lerp(nek.rotation.z, deg_to_rad(0.0), delta * lerp_speed)
		
	# Handle sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle headbobbing
	if !in_dialoge:
		if sprinting:
			head_bobbing_current_intensity = head_bobbing_sprinting_intensity
			head_bobbing_index += head_bobbing_sprinting_speed*delta
		elif walking:
			head_bobbing_current_intensity = head_bobbing_walking_intensity
			head_bobbing_index += head_bobbing_walking_speed*delta
		elif crouching:
			head_bobbing_current_intensity = head_bobbing_crouching_intensity
			head_bobbing_index += head_bobbing_crouching_speed*delta
		if is_on_floor() && !sliding && input_dir!=Vector2.ZERO:
			head_bobing_vector.y = sin(head_bobbing_index)
			head_bobing_vector.x = sin(head_bobbing_index/2)+0.5
			eyes.position.y = lerp(eyes.position.y,head_bobing_vector.y * (head_bobbing_current_intensity/2.0),delta * lerp_speed)
			eyes.position.x = lerp(eyes.position.x,head_bobing_vector.x * (head_bobbing_current_intensity),delta * lerp_speed)
		else:
			eyes.position.y = lerp(eyes.position.y,0.0,delta * lerp_speed)
			eyes.position.x = lerp(eyes.position.x,0.0,delta * lerp_speed)
		if head_bobing_vector.x < -0.20 and can_play_stpe_left:
			_play_sound(footsteps_sounds[randi() % footsteps_sounds.size()])
			can_play_stpe_left = false
			can_play_stpe_right = true
		elif head_bobing_vector.x > 0.90 and can_play_stpe_right:
			_play_sound(footsteps_sounds[randi() % footsteps_sounds.size()])
			can_play_stpe_right = false
			can_play_stpe_left = true
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !ray_cast_3d.is_colliding() and !in_dialoge: 
		if sliding:
			sliding = false
		else:
			velocity.y = JUMP_VELOCITY
			animation_player.play("jumping")
			_play_sound(footsteps_sounds[randi() % footsteps_sounds.size()])	
	# Handle Landing
	if is_on_floor():
		if last_velocity.y < -10.0:
			animation_player.play("roll")

		elif last_velocity.y < -4.0:
			animation_player.play("landing")
			_play_sound(footsteps_sounds[randi() % footsteps_sounds.size()])

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * air_lerp_speed)
		
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		current_speed = (slide_timer+0.1) * slide_speed 
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	last_velocity = velocity
	
	if !in_dialoge:
		handle_stairs()
		move_and_slide()
	

func _play_sound(track:AudioStreamMP3):
	var sound = sound_direct.instantiate()
	add_child(sound)
#	print(current_speed)
	var volume_db = 0
	var pich 
	if current_speed < 4:
		volume_db = -10
		pich = randf_range(0.3,0.6);
	if current_speed > 4 and current_speed < 6:
		volume_db = -2
		pich = randf_range(0.8,1.2);
	if current_speed > 6:
		volume_db = 4
		pich = randf_range(1.3,1.6);
	sound.play_sound(track,volume_db,pich )
	



func try_interact():
	var collider = interaction_grabing.get_collider()
	if collider != null and collider.is_in_group("Interactable"):
		collider.interact()
		if collider.has_method("talk"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			in_dialoge = true
			collider.talk()
	
	

func pick_object():
	if picked_object == null:
		hand.position.y = -0.7
		var collider = interaction_grabing.get_collider()
		if collider !=null and collider is RigidBody3D and collider.is_in_group("holdable") :
#			print("złapałem")
			picked_object = collider
			joint.set_node_b(picked_object.get_path())
			if collider.has_method("disable_collisions"):
				picked_object.disable_collisions();
				
				
#			
			
	
func remove_object():
	if picked_object != null:
#		print("puściłem")
		if picked_object.has_method("enable_collisions"):
			picked_object.enable_collisions()
		picked_object = null
		grab_delay.start()
		can_grab = false
		joint.set_node_b(joint.get_path())

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body.rotate_y(deg_to_rad(event.relative.x * rotation_power)) 


func _on_grab_delay_timeout():
	can_grab = true





func _on_talk_timer_timeout() -> void:
	print("Ping")
	in_dialoge = false


func _on_drop_check_body_entered(body: Node3D) -> void:
	can_drop = false
	print("in")

func _on_drop_check_body_exited(body: Node3D) -> void:
	can_drop = true
	print("out")
