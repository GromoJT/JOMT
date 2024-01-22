extends Camera3D

@onready var weapon_menager: Node3D = $fps_rig/Weapon_Menager
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var shoot_ray: RayCast3D = $ShootRay
@onready var impact_place: Marker3D = $ShootRay/impactPlace
@onready var test_mesh: MeshInstance3D = $ShootRay/test_mesh


var is_ADS : bool = false
var active_gun : Weapon_Resource

var bullet_m9 = preload("res://assets/models/guns/bullet/bullet.tscn")
var instance

func _ready() -> void:
	if active_gun.Weapon_Name != "nothing":
		get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).get_node("Armature/AnimationPlayer").queue(active_gun.Shoot_Anim)

func weapon_up_signal() -> void:
	weapon_menager.changeGunUp()
	active_gun = weapon_menager.get_active_gun()
func weapon_down_signal() -> void:
	weapon_menager.changeGunDown()
	active_gun = weapon_menager.get_active_gun()
func shoot() -> void:
	get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).get_node("Armature/AnimationPlayer").queue(active_gun.Shoot_Anim)
	get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).get_node("Armature/AudioStreamPlayer").play()
	if shoot_ray.is_colliding() and shoot_ray.get_collider().is_in_group("enemy"):
		shoot_ray.get_collider().hit()
		
func ADS_In() -> void:
	if is_ADS == false:
		is_ADS = true;
		animation_player.queue(active_gun.Aim_In_Anim)
		get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).translate(active_gun.ADS_in_pos)
		get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).set_rotation_degrees(active_gun.ADS_in_rot)

func ADS_Out() -> void:
	if is_ADS:
		is_ADS = false
		animation_player.queue(active_gun.Aim_Out_Anim)
		get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).translate(active_gun.ADS_out_pos)
		get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).set_rotation_degrees(active_gun.ADS_out_rot)



