extends Node3D

@onready var deer_sign: Node3D = $NavigationRegion3D/World/Miscs/deer_sign
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var player: CharacterBody3D = $Player
const HELLISH_SKY_SHADER_MATERIAL = preload("res://scenes/Levels/MantionHub/hellish_sky_shader_material.tres")
func zombie_deer_attack() -> void:
	world_environment.environment.sky.sky_material = HELLISH_SKY_SHADER_MATERIAL

