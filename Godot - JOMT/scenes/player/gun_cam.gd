extends Camera3D

@onready var weapon_menager: Node3D = $fps_rig/Weapon_Menager
@onready var animation_player: AnimationPlayer = %AnimationPlayer
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
	instance = bullet_m9.instantiate()
	instance.position = get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).get_node("gun_barrel").global_position
	instance.transform.basis = get_node("fps_rig/Weapon_Menager").get_node(active_gun.Weapon_Name).get_node("gun_barrel").global_transform.basis
	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().add_child(instance)
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

	
