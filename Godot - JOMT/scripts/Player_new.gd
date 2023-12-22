#extends StairsCharacter
extends CharacterBody3D
# Player nodes
#---------------#

#---Coliders---#
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape

#---CollidersCheks--#
@onready var ray_cast_crouching = $RayCastCrouching

#---BodyParts---#
@onready var nek: Node3D = $Nek
@onready var head: Node3D = $Nek/Head
@onready var eyes: Node3D = $Nek/Head/Eyes

#---MainCameraTree---#
@onready var main_camera_3d: Camera3D = $Nek/Head/Eyes/MainCamera3D
#+++Interaction+++#
@onready var lean_area_detector_l: Area3D = $Lean_area_detector_L
@onready var lean_area_detector_r: Area3D = $Lean_area_detector_R


@onready var interaction_grabbing_ray: RayCast3D = $Nek/Head/Eyes/MainCamera3D/Interaction_grabbing_ray
@onready var drop_check: Area3D = $Nek/Head/Eyes/MainCamera3D/Drop_check
@onready var double_drop_check: RayCast3D = $Nek/Head/Eyes/MainCamera3D/Double_Drop_check
@onready var hand: Marker3D = $Nek/Head/Eyes/MainCamera3D/Hand
@onready var joint: Generic6DOFJoint3D = $Nek/Head/Eyes/MainCamera3D/Generic6DOFJoint3D
@onready var static_body_for_grabbed_item: StaticBody3D = $Nek/Head/Eyes/MainCamera3D/SB_for_grabbed_item
@onready var throw_pos: Marker3D = $Nek/Head/Eyes/MainCamera3D/Throw_pos
@onready var anti_in_wall_walking_ray: RayCast3D = $Nek/Head/Anti_in_wall_walking_ray
#+++SubView+++#
@onready var gun_cam: Camera3D = $Nek/Head/Eyes/MainCamera3D/SubViewportContainer/SubViewport/GunCam
#+++AnimationPlayer+++#
@onready var animation_player = $Nek/Head/Eyes/AnimationPlayer
#+++Flashlight+++#
@onready var Flashlight: SpotLight3D = $Nek/Head/Flashlight

#---Audio---#
@onready var audio_stream_player: AudioStreamPlayer = $PlayerAudio/AudioStreamPlayer

#---UI---#
@onready var ui: CanvasLayer = $UI_controller/UI
@onready var pouse_menu: ColorRect = $Game_UI/PouseMenu

#---InventoryInterface---#
@export var inventory_data: InventoryData
@onready var inventory_interface: Control = $InventoryInterface
@onready var grabed_slot: PanelContainer = $InventoryInterface/GrabedSlot

#---Timers---#
@onready var grab_delay:Timer = $Grab_delay
@onready var talk_timer: Timer = $Talk_timer
@onready var anti_bunny_hop: Timer = $AntiBunnyHop
@onready var anti_slide: Timer = $AntiSlide

#---SIGNALS---#
signal send_pick_up_item_to_geometry(slotData:SlotData,position:Vector3)

#---PRELOADES---#
var sound_direct = preload("res://audio/sound_direct.tscn")
#const PickUp = preload("res://scripts/item/pick_ups/pick_up.tscn")


#---externalNodes---#
@export var footsteps_sounds : Array[AudioStreamMP3]

# Speed vars
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
@export var slide_speed = 10.0

var last_horizontal_pos : Vector2 = Vector2.ZERO
var HV: float

# State Machine
var walking: bool = false
var sprinting: bool = false
var crouching: bool = false
var free_looking: bool = false
var sliding: bool = false
var slideable: bool = false
var leaning_left: bool = false
var leaning_right: bool = false
var locked_look: bool = false
var can_grab: bool = true
var in_dialoge: bool = false
var moon_walk: bool = false
var poused: bool = false
var in_external_inventory: bool = false
var can_jump: bool = true
var can_play_stpe_left: bool = true
var can_play_stpe_right: bool = true
var can_lean_left:bool = true
var can_lean_right:bool = true
var can_head_boob:bool = true
# Slide vars

var slide_timer: float = 0.0
var slide_timer_max: float = 1.0
var slide_vector: Vector2 = Vector2.ZERO
var anti_slide_timer_finished:bool = true;
var last_player_y_lock: bool = false
var last_player_y_pos:float = 0
var cur_player_y_pos:float = 0

# Head bobbing vars

const head_bobbing_sprinting_speed: float = 22.0
const head_bobbing_walking_speed: float = 14.0
const head_bobbing_crouching_speed: float = 10.0

const head_bobbing_sprinting_intensity: float = 0.25
const head_bobbing_walking_intensity: float = 0.1
const head_bobbing_crouching_intensity: float = 0.05
var head_bobbing_current_intensity: float = 0.0

var head_bobing_vector: Vector2 = Vector2.ZERO
var head_bobbing_index: float = 0.0

# Player atributes
@export var player_height: float = 1.8
@export var mouse_sens: float = 0.25

# semi CONSTS
var current_speed: float = 5.0
const JUMP_VELOCITY: float = 4.5

# crouch settings
var lerp_speed: float = 15.0
var air_lerp_speed: float = 1.5
var crouching_depth: float = -0.9

# leaning settings
var lean_pos_x: float = 0.46
var lean_pos_y: float = player_height - 0.15
var lean_rot_z: float = deg_to_rad(15)

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
@onready var sub_viewport: SubViewport = $Nek/Head/Eyes/MainCamera3D/SubViewportContainer/SubViewport

@onready var un_pause_timeout: Timer = $UI_controller/UnPauseTimeout
var last_a 
var last_b

#	Start
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.itsOver.connect(_on_dialogue_ended)
	pouse_menu.visible = false
	pouse_menu.unPouse.connect(visionBack)
	inventory_interface.set_player_inventory_data(inventory_data)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_function)
#	super()


func _input(event):
	if event is InputEventMouseMotion and !in_dialoge and !inventory_interface.visible:
		if !locked_look:
			if free_looking:
				nek.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
				nek.rotation.y = clamp(nek.rotation.y,deg_to_rad(-160),deg_to_rad(160))
			else:
				rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
			if picked_object != null:
				picked_object.rotate_x(deg_to_rad(event.relative.x * mouse_sens))
		else:
			rotate_object(event)

func _process(_delta: float) -> void:
	gun_cam.global_transform = main_camera_3d.global_transform
	drop_check.global_transform = hand.global_transform


func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	last_horizontal_pos = Vector2(position.x,position.z)
	anti_in_wall_walking_ray.target_position= Vector3(input_dir.x,0,input_dir.y)
	#print(input_dir.x)
	
	
	
	declare_moon_walk(input_dir)
	
	if Input.is_action_just_pressed("Light"):
		toggle_personal_light()
	
	if Input.is_action_just_pressed("esc") and get_tree().paused == false and poused == false and !in_dialoge:
		open_esc_menu()
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory_function()
	
	if Input.is_action_just_pressed("interact") and !in_dialoge and !inventory_interface.visible:
		try_interact()
		
	# Handle piking things up
	if Input.is_action_pressed("interact"):
		base_interaction()

	if Input.is_action_just_released("interact"):
		base_interaction_relese()

	if picked_object != null:
		base_interaction_unhold()
		object_rotation_when_looking_down()

	if Input.is_action_pressed("crouch") and is_on_floor() or sliding and !in_dialoge and !in_external_inventory :
		crouching_func(input_dir,delta)

	elif !ray_cast_crouching.is_colliding():
		un_crouching_func(delta)
		if Input.is_action_pressed("sprint") and !moon_walk:
			sprint_state_func(delta)
		else:
			normal_state_func(delta)

	# Handle freelooking
	if Input.is_action_pressed("free_look") or sliding:
		free_look_func(delta)
	else:
		unfree_look_func(delta)

	# Handle Leaning
	if Input.is_action_pressed("leanL") or Input.is_action_pressed("leanR")\
	and !sliding and !in_dialoge and !in_external_inventory:
		lean_func(delta)
	else:
		unlean_func(delta)
		
		if input_dir.x != 0 and can_lean_left and can_lean_right:
			main_camera_3d.rotation.z = lerp(main_camera_3d.rotation.z,-lean_rot_z/3 * input_dir.x,delta * lerp_speed/3)
		else:	
			main_camera_3d.rotation.z = lerp(main_camera_3d.rotation.z,0.0,delta * lerp_speed/3)
		
	if sliding:
		if !last_player_y_lock:
			last_player_y_pos = get_player_pos_y()
			last_player_y_lock = true
		slide_func(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle headbobbing
	if !in_dialoge and !in_external_inventory:
		head_bobbing_and_steps(input_dir,delta)

	if Input.is_action_just_pressed("jump") and is_on_floor() and !ray_cast_crouching.is_colliding() and !in_dialoge and !in_external_inventory and can_jump: 
		jumping_func()

	if is_on_floor():
		landing_func()
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
	
	if !in_dialoge and !in_external_inventory:
#		handle_stairs()
		move_and_slide()
		HV = Vector2((position.x-last_horizontal_pos.x)/delta ,(position.z-last_horizontal_pos.y)/delta).length()
#		print(HV)
		
func toggle_inventory_function(external_inventory_owner = null)->void:
	if !in_dialoge:
		inventory_interface.visible = !inventory_interface.visible
		if inventory_interface.visible == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if external_inventory_owner:
			inventory_interface.set_external_inventory(external_inventory_owner)
			in_external_inventory = true
		else:
			inventory_interface.clear_external_inventory()
			in_external_inventory = false

func toggle_personal_light() -> void:
	Flashlight.visible = !Flashlight.visible

func declare_moon_walk(input_dir) -> void:
	if input_dir.x<0 and input_dir.y>0 or input_dir.x==0 and input_dir.y==1 or input_dir.x>0 and input_dir.y>0:
		moon_walk = true
	else:
		moon_walk = false

func base_interaction() -> void:
	if can_grab and !inventory_interface.visible:
			pick_object()
			if Input.is_action_just_pressed("interact_2"):
				if picked_object != null:
					if can_drop:
						if double_drop_check.get_collider() == null:
							joint.set_node_b(joint.get_path())
							picked_object.global_position = throw_pos.global_position
							var knokback = picked_object.global_position - eyes.global_position
							picked_object.apply_central_impulse(knokback * 20)
						remove_object()
			if Input.is_action_pressed("free_look"):
				locked_look = true
			else:
				locked_look = false

func base_interaction_relese() -> void:
	locked_look = false
	if can_drop:
		if double_drop_check.get_collider() == null:
			remove_object()

func base_interaction_unhold() -> void:
	if !Input.is_action_pressed("interact"):
		locked_look = false
		if can_drop:
			if double_drop_check.get_collider() == null:
				remove_object()

func open_esc_menu() -> void:
	if in_external_inventory:
		pass
	else:
		inventory_interface.visible = false
		pouse_menu.visible = !pouse_menu.visible
		ui.visible = false
		poused = true
		pouse_menu.pause()

func object_rotation_when_looking_down() -> void:
	if rad_to_deg(head.rotation.x) < -40:
		hand.position = Vector3(0.6,-0.5,-0.8)
	else:
		hand.position = Vector3(0,-0.5,-1.3)
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a) * pull_power)

func crouching_func(input_dir,delta) -> void:
	current_speed = lerp(current_speed,crouching_speed,delta * lerp_speed)
	head.position.y = lerp(head.position.y,crouching_depth,delta * lerp_speed)
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	lean_area_detector_l.position.y = 0.8
	lean_area_detector_r.position.y = 0.8
	if sprinting and input_dir != Vector2.ZERO and is_on_floor() and slideable and !moon_walk:
		sliding = true
		slide_timer = slide_timer_max
		slide_vector = input_dir
		free_looking = true
		
	walking = false
	sprinting = false
	crouching = true

func un_crouching_func(delta) -> void:
	head.position.y = lerp(head.position.y,0.0,delta * lerp_speed)
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	lean_area_detector_l.position.y = 1.7
	lean_area_detector_r.position.y = 1.7
	
func sprint_state_func(delta) -> void:
	current_speed = lerp(current_speed,sprinting_speed,delta * (lerp_speed/3))
	if current_speed > 7.5 and HV>6 and anti_slide_timer_finished:
		slideable = true;
	else:
		slideable = false;
	walking = false
	sprinting = true
	crouching = false

func normal_state_func(delta) -> void:
	current_speed = lerp(current_speed,walking_speed,delta * lerp_speed)
	walking = true
	sprinting = false
	crouching = false

func free_look_func(delta) -> void:
	free_looking = true
	if sliding:
		eyes.rotation.z = lerp(eyes.rotation.z,-deg_to_rad(7.0), delta * lerp_speed)
	else:
		eyes.rotation.z = -deg_to_rad(nek.rotation.y * free_look_tilt_amount)

func unfree_look_func(delta) -> void:
	free_looking = false
	nek.rotation.y = lerp(nek.rotation.y,deg_to_rad(0.0),delta * lerp_speed)
	eyes.rotation.z = lerp(eyes.rotation.z,deg_to_rad(0.0),delta * lerp_speed)

func lean_func(delta) -> void:

	if Input.is_action_pressed("leanL") and can_lean_left and Input.is_action_pressed("leanR") and can_lean_right and !free_looking:
		pass
	elif Input.is_action_pressed("leanL") and can_lean_left and !free_looking:
		leaning_left = true
		nek.position.x = lerp(nek.position.x, -lean_pos_x*1.75, delta * lerp_speed/3)
		nek.position.y = lerp(nek.position.y, lean_pos_y, delta * lerp_speed/3)
		nek.rotation.z = lerp(nek.rotation.z,lean_rot_z,delta * lerp_speed/3)
	elif Input.is_action_pressed("leanR") and can_lean_right and !free_looking:
		leaning_right = true
		nek.position.x = lerp(nek.position.x, lean_pos_x*1.75, delta * lerp_speed/3)
		nek.position.y = lerp(nek.position.y, lean_pos_y, delta * lerp_speed/3)
		nek.rotation.z = lerp(nek.rotation.z,-lean_rot_z,delta * lerp_speed/3)
	else:
		unlean_func(delta)

func unlean_func(delta) -> void:

	nek.position.x = lerp(nek.position.x, 0.0, delta * lerp_speed)
	nek.position.y = lerp(nek.position.y, player_height, delta * lerp_speed)
	nek.rotation.z = lerp(nek.rotation.z, deg_to_rad(0.0), delta * lerp_speed)

func slide_func(delta) -> void:
	cur_player_y_pos = get_player_pos_y()
#	print(last_player_y_pos - cur_player_y_pos)
#	Engine.time_scale = 0.3
	anti_slide.start()
	anti_slide_timer_finished = false;
	if cur_player_y_pos > last_player_y_pos+0.1:
		slide_timer -= delta * (1.5 + abs(last_player_y_pos - cur_player_y_pos))
	else:
		slide_timer -= delta
	if slide_timer <= 0:
		sliding = false
		free_looking = false
		last_player_y_lock = false
#		Engine.time_scale = 1

func get_player_pos_y() -> float:
	return position.y

func head_bobbing_and_steps(input_dir,delta) -> void:
#	print("hbob -> ",HV)
	if HV > walking_speed + 0.5:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif HV > crouching_speed+0.5 and HV < walking_speed + 0.5 :
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif HV < crouching_speed + 0.5 :
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
	if is_on_floor() && !sliding && input_dir!=Vector2.ZERO and HV > 0.5 :
		head_bobing_vector.y = sin(head_bobbing_index)
		head_bobing_vector.x = sin(head_bobbing_index/2)+0.5
		if can_head_boob: 
			eyes.position.y = lerp(eyes.position.y,head_bobing_vector.y * (head_bobbing_current_intensity/2.0),delta * lerp_speed)
			eyes.position.x = lerp(eyes.position.x,head_bobing_vector.x * (head_bobbing_current_intensity),delta * lerp_speed)
		else:
			eyes.position.y = lerp(eyes.position.y,0.0,delta * lerp_speed)
			eyes.position.x = lerp(eyes.position.x,0.0,delta * lerp_speed)
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

func jumping_func() -> void:
	if sliding:
		sliding = false
	else:
		can_jump = false
		anti_bunny_hop.start()
		velocity.y = JUMP_VELOCITY
		animation_player.play("jumping")
		_play_sound(footsteps_sounds[randi() % footsteps_sounds.size()])

func landing_func() -> void:
	if last_velocity.y < -10.0:
		animation_player.play("landing")
	elif last_velocity.y < -4.0:
		animation_player.play("landing")
		_play_sound(footsteps_sounds[randi() % footsteps_sounds.size()])


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
	var collider = interaction_grabbing_ray.get_collider()
	if collider != null and collider.is_in_group("Interactable"):
		collider.interact()
		if collider.has_method("talk"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			in_dialoge = true
			collider.talk()
	if collider != null and collider.is_in_group("external_inventory"):
			collider.player_interact()

func pick_object():
	if picked_object == null:
		hand.position.y = -0.7
		var collider = interaction_grabbing_ray.get_collider()
		if collider !=null and collider is RigidBody3D and collider.is_in_group("holdable"):
#			print("test")
			picked_object = collider
			joint.set_node_b(picked_object.get_path())
			if collider.has_method("disable_collisions"):
				picked_object.disable_collisions();

func remove_object():
	if picked_object != null:
		if picked_object.has_method("enable_collisions"):
			picked_object.enable_collisions()
		picked_object = null
		grab_delay.start()
		can_grab = false
		joint.set_node_b(joint.get_path())

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			static_body_for_grabbed_item.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body_for_grabbed_item.rotate_y(deg_to_rad(event.relative.x * rotation_power)) 

func visionBack():
	ui.visible = true
	pouse_menu.visible = false
	un_pause_timeout.start()
	if !in_dialoge:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_dialogue_ended():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	talk_timer.start()

func _on_grab_delay_timeout():
	can_grab = true

func _on_talk_timer_timeout() -> void:
	in_dialoge = false

func _on_drop_check_body_entered(_body: Node3D) -> void:
	can_drop = false

func _on_drop_check_body_exited(_body: Node3D) -> void:
	can_drop = true

func _on_un_pause_timeout_timeout() -> void:
	poused = false

func _on_anti_bunny_hop_timeout() -> void:
	can_jump = true

func _on_inventory_interface_drop_slot_data(slot_data) -> void:
	#send_pick_up_item_to_geometry.emit(slot_data,get_drop_position())
	Globals.player_send_pick_up_item_to_geometry(slot_data,get_drop_position())

func get_drop_position() -> Vector3:
	var cam_dir = -main_camera_3d.global_transform.basis.z
	return main_camera_3d.global_position+cam_dir 

func _on_lean_area_detector_l_body_entered(_body: Node3D) -> void:
#	print("L-wykrywa")
	can_lean_left = false

func _on_lean_area_detector_l_body_exited(_body: Node3D) -> void:
#	print("L-NIE wykrywa")
	can_lean_left = true

func _on_lean_area_detector_r_body_entered(_body: Node3D) -> void:
#	print("R-wykrywa")
	can_lean_right = false

func _on_lean_area_detector_r_body_exited(_body: Node3D) -> void:
#	print("R-NIE wykrywa")
	can_lean_right = true


func _on_player_body_area_3d_area_entered(area: Area3D) -> void:
		if area.is_in_group("Portal"):
			position.x = 2.817
			position.y = -17.517
			position.z = 12.682

func _on_anit_head_bump_body_entered(_body: Node3D) -> void:
	can_head_boob = false

func _on_anit_head_bump_body_exited(_body: Node3D) -> void:
	can_head_boob = true


func _on_anti_slide_timeout() -> void:
	anti_slide_timer_finished = true;
