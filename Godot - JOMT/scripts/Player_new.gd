#extends StairsCharacter
extends CharacterBody3D
# Player nodes
#---------------#

#---Coliders---#
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape

#---CollidersCheks--#
@onready var ray_cast_crouching = $RayCastCrouching
#@onready var drop_up_ray_cast: RayCast3D = $dropUpRayCast
@onready var drop_up_ray_cast: RayCast3D = $Nek/Head/Eyes/MainCamera3D/Interaction_grabbing_ray/dropUpRayCast

#@onready var test_mesh: MeshInstance3D = $dropUpRayCast/testMesh
#@onready var test_mesh: MeshInstance3D = $Nek/Head/Eyes/MainCamera3D/Interaction_grabbing_ray/dropUpRayCast/testMesh
@onready var test_mesh: MeshInstance3D = $Nek/Head/Eyes/MainCamera3D/Interaction_grabbing_ray/testMesh


@onready var upstairs_colision_shape: CollisionShape3D = $UpstairsColisionShape
@onready var _initial_separation_ray_dist = abs(upstairs_colision_shape.position.z)


#---BodyParts---#
@onready var nek: Node3D = $Nek
@onready var head: Node3D = $Nek/Head
@onready var eyes: Node3D = $Nek/Head/Eyes

#---MainCameraTree---#
@onready var main_camera_3d: Camera3D = $Nek/Head/Eyes/MainCamera3D

#+++Interaction+++#
@onready var lean_area_detector_l: Area3D = $Areas/Lean_area_detector_L
@onready var lean_area_detector_r: Area3D = $Areas/Lean_area_detector_R
@onready var drop_point: Marker3D = $Nek/Head/Eyes/MainCamera3D/Interaction_grabbing_ray/Drop_point


@onready var interaction_grabbing_ray: RayCast3D = $Nek/Head/Eyes/MainCamera3D/Interaction_grabbing_ray
@onready var drop_check: Area3D = $Nek/Head/Eyes/MainCamera3D/Drop_check
@onready var double_drop_check: RayCast3D = $Nek/Head/Eyes/MainCamera3D/Double_Drop_check
@onready var hand: Marker3D = $Nek/Head/Eyes/MainCamera3D/Hand
#@onready var joint: JoltGeneric6DOFJoint3D = $Nek/Head/Eyes/MainCamera3D/JoltGeneric6DOFJoint3D
@onready var joint: JoltGeneric6DOFJoint3D = $Nek/Head/Eyes/MainCamera3D/Hand/JoltGeneric6DOFJoint3D

#@onready var static_body_for_grabbed_item: StaticBody3D = $Nek/Head/Eyes/MainCamera3D/SB_for_grabbed_item
@onready var static_body_for_grabbed_item: StaticBody3D = $Nek/Head/Eyes/MainCamera3D/Hand/SB_for_grabbed_item

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
@onready var footsteps_profile : String = "NULL"
#---UI---#
@onready var ui: CanvasLayer = $UI_controller/UI
@onready var pouse_menu: ColorRect = $Game_UI/PouseMenu

#---InventoryInterface---#
@export var inventory_data: InventoryData
@onready var inventory_interface: Control = $InventoryInterface
@onready var grabed_slot: PanelContainer = $InventoryInterface/GrabedSlot

#---Timers---#
@onready var grab_delay:Timer = $Timers/Grab_delay
@onready var talk_timer: Timer = $Timers/Talk_timer
@onready var anti_bunny_hop: Timer = $Timers/AntiBunnyHop
@onready var anti_slide: Timer = $Timers/AntiSlide
@onready var exhaustion_timer: Timer = $Timers/ExhaustionTimer
@onready var stamina_regen_timer: Timer = $Timers/StaminaRegenTimer

#---SIGNALS---#
signal send_pick_up_item_to_geometry(slotData:SlotData,position:Vector3)

#---PRELOADES---#
var sound_direct = preload("res://audio/sound_direct.tscn")
#const PickUp = preload("res://scripts/item/pick_ups/pick_up.tscn")

#---externalNodes---#
@export var footsteps_sounds : Array[AudioStreamMP3]

# Speed vars
@export var walking_speed = 5.0
@export var slow_walk_speed = 3.2
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
@export var slide_speed = 10.0

var last_horizontal_pos : Vector2 = Vector2.ZERO
var HV: float

# State Machine
var walking: bool = false
var sprinting: bool = false
var crouching: bool = false
var slow_walking: bool = false
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
var can_move:bool = true
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
const head_bobbing_slow_walking_speed: float = 7.0

const head_bobbing_sprinting_intensity: float = 0.25
const head_bobbing_walking_intensity: float = 0.1
const head_bobbing_crouching_intensity: float = 0.05
const head_bobbing_slow_walking_intensity: float = 0.05
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
var pull_power = 56
var rotation_power = 2
var can_drop = true
var gun_in_hand : bool = true
var havy_item : bool = false

var push_force: float = 2.0

@onready var sub_viewport: SubViewport = $Nek/Head/Eyes/MainCamera3D/SubViewportContainer/SubViewport

@onready var un_pause_timeout: Timer = $UI_controller/UnPauseTimeout
var last_a 
var last_b

#Stamina
@export var max_stamina : float = 100.0
var cur_stamina : float = 0.0
var can_regen : bool = false
var exhaustion : bool = false
var is_realxig : bool = false


var test_object_sieze : Vector3 = Vector3.ZERO
#	Start
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.itsOver.connect(_on_dialogue_ended)
	pouse_menu.visible = false
	cur_stamina = max_stamina
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

var drop_dist : float = 0.0
var drop_normal : Vector3 = Vector3.ZERO

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	last_horizontal_pos = Vector2(position.x,position.z)
	anti_in_wall_walking_ray.target_position= Vector3(input_dir.x,0,input_dir.y)
	

	
	if Input.is_action_just_released("Interact"):
		if interaction_grabbing_ray.is_colliding() :
			if interaction_grabbing_ray.get_collider().is_in_group("Interactable"):
				if interaction_grabbing_ray.get_collider().is_in_group("Door"):
					interaction_grabbing_ray.get_collider().get_parent().get_parent().get_parent().Interact(interaction_grabbing_ray.get_collider())
	
	#print(input_dir.x)
	
	#print(Engine.get_frames_per_second())
	#if $GroundSurfaceChecker.get_collider() is Terrain3D:
		#print("off")
		#$UpstairsColisionShape.disabled = true
		#$UpstairsColisionShapeL.disabled = true
		#$UpstairsColisionShapeL2.disabled = true
		#$UpstairsColisionShapeR.disabled = true
		#$UpstairsColisionShapeR2.disabled = true
		#$UpstairsColisionShape/RayCast3D.enabled = false
		#$UpstairsColisionShapeL/RayCast3D2.enabled = false
		#$UpstairsColisionShapeL2/RayCast3D3.enabled = false
		#$UpstairsColisionShapeR/RayCast3D4.enabled = false
		#$UpstairsColisionShapeR2/RayCast3D5.enabled = false
	#else:
		#print("on")
		#$UpstairsColisionShape.disabled = false
		#$UpstairsColisionShapeL.disabled = false
		#$UpstairsColisionShapeL2.disabled = false
		#$UpstairsColisionShapeR.disabled = false
		#$UpstairsColisionShapeR2.disabled = false
		#$UpstairsColisionShape/RayCast3D.enabled = true
		#$UpstairsColisionShapeL/RayCast3D2.enabled = true
		#$UpstairsColisionShapeL2/RayCast3D3.enabled = true
		#$UpstairsColisionShapeR/RayCast3D4.enabled = true
		#$UpstairsColisionShapeR2/RayCast3D5.enabled = true
		
	#print(main_camera_3d.global_rotation_degrees)
	#if drop_up_ray_cast != null:
		#print(drop_up_ray_cast.global_rotation_degrees)
	#drop_up_ray_cast.position = interaction_grabbing_ray.get_target_position()
	if main_camera_3d.global_rotation_degrees.x < -55:
		interaction_grabbing_ray.target_position.z = -2.2
		#print("*")
	else:
		interaction_grabbing_ray.target_position.z = -2
		#print("_")
	drop_up_ray_cast.rotation_degrees.x = -main_camera_3d.global_rotation_degrees.x
	throw_pos.position = Vector3(0,0,-0.3)
	if interaction_grabbing_ray.is_colliding():
		
		if interaction_grabbing_ray.get_collision_normal().y>0.45:
			drop_up_ray_cast.enabled = true
			drop_up_ray_cast.global_position = interaction_grabbing_ray.get_collision_point() - Vector3(0,0.1,0)
		else:
			drop_normal = interaction_grabbing_ray.get_collision_normal().normalized() 
			drop_up_ray_cast.enabled = false
			drop_point.global_position = interaction_grabbing_ray.get_collision_point() + (drop_normal * (drop_dist * 1.1))
			test_mesh.global_position = drop_point.global_position
	else:
		drop_up_ray_cast.enabled = false

		
	if drop_up_ray_cast.is_colliding():
		
		drop_normal = Vector3(0,drop_dist * 1.1,0)
		drop_point.global_position = interaction_grabbing_ray.get_collision_point() + drop_normal
		test_mesh.global_position = drop_point.global_position
		throw_pos.global_position = drop_point.global_position
		#test_mesh.visible = true;

	if !drop_up_ray_cast.is_colliding() and !interaction_grabbing_ray.is_colliding():
		drop_point.position = interaction_grabbing_ray.target_position
		test_mesh.global_position = drop_point.global_position
		
	if picked_object != null:
		drop_dist = max(test_object_sieze.x,test_object_sieze.y,test_object_sieze.z) / 2
		
	can_lean_func()
	#print(cur_stamina)
	declare_moon_walk(input_dir)
	
	Globals.stamina = cur_stamina;

	if havy_item:
		walking_speed = 3.0
		slow_walk_speed = 2.2
		crouching_speed = 1.5

	else:
		walking_speed = 5.0
		slow_walk_speed = 3.2
		crouching_speed = 3.0

	
	if gun_cam.active_gun.Weapon_Name == "nothing":
		gun_in_hand = false
		gun_cam.is_ADS = false
	else:
		gun_in_hand = true
	
	ui.get_node("Control/Label").visible = !gun_cam.is_ADS
	
	if Input.is_action_just_released("weapon_up") and picked_object == null:
		gun_cam.weapon_up_signal()
	if Input.is_action_just_released("weapon_down") and picked_object == null:
		gun_cam.weapon_down_signal()
	
	if Input.is_action_just_pressed("lamp"):
		toggle_personal_light()
	
	if Input.is_action_just_pressed("esc") and get_tree().paused == false and poused == false and !in_dialoge:
		open_esc_menu()
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory_function()
	

	if Input.is_action_just_pressed("LMB") and !in_dialoge and !inventory_interface.visible and !gun_in_hand:

		try_interact()
	elif Input.is_action_just_pressed("LMB") and !in_dialoge and gun_in_hand:
		gun_cam.shoot()

		
	if Input.is_action_pressed("RMB") and !in_dialoge and gun_in_hand:
		gun_cam.ADS_In()
		
	if Input.is_action_just_released("RMB")  and !in_dialoge and gun_in_hand and gun_cam.is_ADS:
		
		gun_cam.ADS_Out()
	# Handle piking things up
	if Input.is_action_pressed("LMB"):
		base_interaction()

	if Input.is_action_just_released("LMB"):
		base_interaction_relese()

	if picked_object != null:
		base_interaction_unhold()
		object_rotation_when_looking_down(delta)

	if Input.is_action_pressed("crouch") and is_on_floor() or sliding and !in_dialoge and !in_external_inventory :
		crouching_func(input_dir,delta)
	elif ray_cast_crouching.is_colliding() :
		crouching_func(input_dir,delta)
	elif !ray_cast_crouching.is_colliding():
		un_crouching_func(delta)
		if Input.is_action_pressed("sprint") and !moon_walk and cur_stamina > 0 and !havy_item:
			sprint_state_func(delta)
		elif Input.is_action_pressed("slow_walk") and is_on_floor():
			slow_walk_state_func(delta)
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
			main_camera_3d.rotation.z = lerp(main_camera_3d.rotation.z,-lean_rot_z/6 * input_dir.x,delta * lerp_speed/3)
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
	
	
	if sprinting and is_on_floor() and HV > walking_speed:
		is_realxig = false
		can_regen = false
		stamina_drain(10,false,delta)
	elif havy_item and is_on_floor():
		is_realxig = false
		can_regen = false
		stamina_drain(5 + 1 * HV,false,delta)
		if cur_stamina <= 0 :
			can_move = false
	else:
		if !is_realxig and is_on_floor():
			is_realxig = true
			can_move = true
			stamina_regen_timer.start()
	
	if can_regen:
		if cur_stamina < max_stamina:
			cur_stamina = cur_stamina + (20 * delta)
	
	if !in_dialoge and !in_external_inventory and can_move:
		#handle_stairs()

		_rotate_step_up_separation_ray()
		move_and_slide()
		_snap_down_to_stairs_check()
		
		HV = Vector2((position.x-last_horizontal_pos.x)/delta ,(position.z-last_horizontal_pos.y)/delta).length()
		#print(HV)
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				#print("bingo")
				#print(-c.get_normal())
				#print(direction)
				c.get_collider().apply_impulse((-c.get_normal() * push_force * HV) )
				
		
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
	if can_grab and !inventory_interface.visible and !gun_in_hand:
			pick_object()
			
			if Input.is_action_just_pressed("RMB"):
				if picked_object != null:
					if (can_drop and picked_object.has_method("disable_collisions")) or (!can_drop and !picked_object.has_method("disable_collisions")) or (can_drop and !picked_object.has_method("disable_collisions")) :
						#if double_drop_check.get_collider() == null:
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
	if picked_object != null:
		if (can_drop and picked_object.has_method("disable_collisions")) or (!can_drop and !picked_object.has_method("disable_collisions")) or (can_drop and !picked_object.has_method("disable_collisions")):
			#if double_drop_check.get_collider() == null:
			remove_object()

func base_interaction_unhold() -> void:
	if !Input.is_action_pressed("LMB"):
		locked_look = false
		if picked_object != null:
			if (can_drop and picked_object.has_method("disable_collisions")) or (!can_drop and !picked_object.has_method("disable_collisions")) or (can_drop and !picked_object.has_method("disable_collisions")):
				#if double_drop_check.get_collider() == null:
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

func object_rotation_when_looking_down(_delta) -> void:
	if rad_to_deg(head.rotation.x) < -40:
		hand.position = Vector3(0.6,-0.3,-0.8)
	else:
		hand.position = Vector3(0,-0.3,-1.3)
	if picked_object != null:
		picked_object.global_position = static_body_for_grabbed_item.global_position
		
		#picked_object.set_linear_velocity((b-a) * pull_power)

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
	slow_walking = false

func un_crouching_func(delta) -> void:
	head.position.y = lerp(head.position.y,0.0,delta * lerp_speed)
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	lean_area_detector_l.position.y = 1.7
	lean_area_detector_r.position.y = 1.7
	
func sprint_state_func(delta) -> void:
	if cur_stamina > 0 and !exhaustion:
		current_speed = lerp(current_speed,sprinting_speed,delta * (lerp_speed/3))
		if current_speed > 7.5 and HV>6 and anti_slide_timer_finished:
			slideable = true;
		else:
			slideable = false;
		walking = false
		sprinting = true
		crouching = false
		slow_walking = false

func slow_walk_state_func(delta) -> void:
	current_speed = lerp(current_speed,slow_walk_speed,delta * (lerp_speed/3))
	walking = false
	sprinting = false
	crouching = false
	slow_walking = true

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

func get_player_pos_y() -> float:
	return position.y

func head_bobbing_and_steps(input_dir,delta) -> void:
#	print("hbob -> ",HV)
	if can_move:
		if HV > walking_speed + 0.5:
			head_bobbing_current_intensity = head_bobbing_sprinting_intensity
			head_bobbing_index += head_bobbing_sprinting_speed*delta
		elif HV > slow_walk_speed+0.5 and HV < walking_speed + 0.5 :
			head_bobbing_current_intensity = head_bobbing_walking_intensity
			head_bobbing_index += head_bobbing_walking_speed*delta
		elif HV > crouching_speed+0.2 and HV < slow_walk_speed + 0.5:
			head_bobbing_current_intensity = head_bobbing_slow_walking_intensity
			head_bobbing_index += head_bobbing_slow_walking_speed*delta
		elif HV < crouching_speed + 0.2 :
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
		if cur_stamina > 15:
			can_jump = false
			stamina_drain(15,true,0.0)
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
	if collider != null :
		if collider.has_method("talk"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			in_dialoge = true
			collider.talk()
	if collider != null and collider.is_in_group("external_inventory"):
			collider.player_interact()

func pick_object():
	if picked_object == null:
		#hand.position.y = -0.7
		var collider = interaction_grabbing_ray.get_collider()
		if collider !=null and collider is RigidBody3D and collider.is_in_group("holdable"):
			#print("test")
			
			for c in collider.get_children(): 
				if c is MeshInstance3D:
					test_object_sieze = c.get_aabb().size * Vector3(c.transform.basis.x.length(),c.transform.basis.y.length(),c.transform.basis.z.length())
			
			picked_object = collider
			#print(picked_object.get_mass())
			if(picked_object.get_mass() > 10):
				havy_item = true
			joint.set_node_b(picked_object.get_path())
			if collider.has_method("disable_collisions"):
				picked_object.disable_collisions();

func remove_object():
	if picked_object != null:
		if picked_object.has_method("enable_collisions"):
			picked_object.enable_collisions()
		picked_object.global_position = drop_point.global_position
		picked_object = null
		test_object_sieze = Vector3.ZERO
		
		havy_item = false
		grab_delay.start()
		can_grab = false
		joint.set_node_b(joint.get_path())

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			#picked_object.global_position = static_body_for_grabbed_item.global_position
			#joint.global_position = static_body_for_grabbed_item.global_position
			
			static_body_for_grabbed_item.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body_for_grabbed_item.rotate_y(deg_to_rad(event.relative.x * rotation_power)) 
			#print("***")
			#print(static_body_for_grabbed_item.global_position)
			#print(picked_object.global_position)
			#print(joint.global_position)
			#
			#picked_object.global_position = static_body_for_grabbed_item.global_position
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

func _on_lean_area_detector_r_body_entered(_body: Node3D) -> void:
	can_lean_right = false

func _on_lean_area_detector_r_body_exited(_body: Node3D) -> void:
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

func set_footsteps_profile(profile : String):
	footsteps_profile = profile
	#print(footsteps_profile)
	
func can_lean_func() -> void:
	if len(lean_area_detector_l.get_overlapping_bodies()) > 0 :
		can_lean_left = false
	else: 
		can_lean_left = true
	if len(lean_area_detector_r.get_overlapping_bodies()) > 0 :
		can_lean_right = false
	else: 
		can_lean_right = true

func stamina_drain(amount:float,_instant:bool,_delta:float)->void:
	if _instant:
		cur_stamina = cur_stamina - 15
		can_regen = false
		stamina_regen_timer.start()
	if cur_stamina > 0:
		cur_stamina = cur_stamina - amount * _delta
	
func _on_stamina_regen_timer_timeout() -> void:
	can_regen = true

var _was_on_floor_last_frame = false
var _snapped_to_stairs_last_frame = false
func _snap_down_to_stairs_check():
	var did_snap = false
	if not is_on_floor() and velocity.y <= 0 and (_was_on_floor_last_frame or _snapped_to_stairs_last_frame) and $GroundSurfaceChecker.is_colliding():
		var body_test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		var max_step_down = -0.5
		params.from = self.global_transform
		params.motion = Vector3(0,max_step_down,0)
		if PhysicsServer3D.body_test_motion(self.get_rid(), params, body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true

	_was_on_floor_last_frame = is_on_floor()
	_snapped_to_stairs_last_frame = did_snap
var _last_xz_vel : Vector3 = Vector3(0,0,0)

var is_a_terain:bool = false

func _rotate_step_up_separation_ray()-> void:
	_is_this_a_terain()
	var xz_vel = velocity * Vector3(1,0,1)
	
	if xz_vel.length() < 0.1:
		xz_vel = _last_xz_vel
	else:
		_last_xz_vel = xz_vel
	
	var xz_f_ray_pos = xz_vel.normalized() * _initial_separation_ray_dist
	upstairs_colision_shape.global_position.x = self.global_position.x + xz_f_ray_pos.x
	upstairs_colision_shape.global_position.z = self.global_position.z + xz_f_ray_pos.z

	var xz_l_ray_pos = xz_f_ray_pos.rotated(Vector3(0,1.0,0),deg_to_rad(-25))
	$UpstairsColisionShapeL.global_position.x = self.global_position.x + xz_l_ray_pos.x
	$UpstairsColisionShapeL.global_position.z = self.global_position.z + xz_l_ray_pos.z
	
	var xz_r_ray_pos = xz_f_ray_pos.rotated(Vector3(0,1.0,0),deg_to_rad(25))
	$UpstairsColisionShapeR.global_position.x = self.global_position.x + xz_r_ray_pos.x
	$UpstairsColisionShapeR.global_position.z = self.global_position.z + xz_r_ray_pos.z

	var xz_l2_ray_pos = xz_f_ray_pos.rotated(Vector3(0,1.0,0),deg_to_rad(-50))
	$UpstairsColisionShapeL2.global_position.x = self.global_position.x + xz_l2_ray_pos.x
	$UpstairsColisionShapeL2.global_position.z = self.global_position.z + xz_l2_ray_pos.z
	
	var xz_r2_ray_pos = xz_f_ray_pos.rotated(Vector3(0,1.0,0),deg_to_rad(50))
	$UpstairsColisionShapeR2.global_position.x = self.global_position.x + xz_r2_ray_pos.x
	$UpstairsColisionShapeR2.global_position.z = self.global_position.z + xz_r2_ray_pos.z
	
	$UpstairsColisionShape/RayCast3D.force_raycast_update()
	$UpstairsColisionShapeL/RayCast3D2.force_raycast_update()
	$UpstairsColisionShapeL2/RayCast3D3.force_raycast_update()
	$UpstairsColisionShapeR/RayCast3D4.force_raycast_update()
	$UpstairsColisionShapeR2/RayCast3D5.force_raycast_update()
	var max_slope_ang_dot = Vector3(0,1,0).rotated(Vector3(1.0,0,0),self.floor_max_angle).dot(Vector3(0,1,0))
	var any_too_steep = false
	#print(max_slope_ang_dot)
	if ($UpstairsColisionShape/RayCast3D.is_colliding() and $UpstairsColisionShape/RayCast3D.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot)  or len($UpstairsColisionShape/Can_I_Fit_1.get_overlapping_bodies()) > 0 or is_a_terain:
		any_too_steep = true
	if ($UpstairsColisionShapeL/RayCast3D2.is_colliding() and $UpstairsColisionShapeL/RayCast3D2.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot) or len($UpstairsColisionShapeL/Can_I_Fit_2.get_overlapping_bodies()) > 0 or is_a_terain:
		any_too_steep = true
	if ($UpstairsColisionShapeL2/RayCast3D3.is_colliding() and $UpstairsColisionShapeL2/RayCast3D3.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot) or len($UpstairsColisionShapeL2/Can_I_Fit_3.get_overlapping_bodies()) > 0 or is_a_terain:
		any_too_steep = true
	if ($UpstairsColisionShapeR/RayCast3D4.is_colliding() and $UpstairsColisionShapeR/RayCast3D4.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot) or len($UpstairsColisionShapeR/Can_I_Fit_4.get_overlapping_bodies()) > 0 or is_a_terain:
		any_too_steep = true
	if ($UpstairsColisionShapeR2/RayCast3D5.is_colliding() and $UpstairsColisionShapeR2/RayCast3D5.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot) or len($UpstairsColisionShapeR2/Can_I_Fit_5.get_overlapping_bodies()) > 0 or is_a_terain:
		any_too_steep = true
	
	$UpstairsColisionShape.disabled = any_too_steep
	$UpstairsColisionShapeL.disabled = any_too_steep
	$UpstairsColisionShapeL2.disabled = any_too_steep
	$UpstairsColisionShapeR.disabled = any_too_steep
	$UpstairsColisionShapeR2.disabled = any_too_steep
	
func _is_this_a_terain():
	if $UpstairsColisionShape/RayCast3D.get_collider() is Terrain3D:
		is_a_terain = true
	else:
		is_a_terain = false
