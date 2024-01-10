extends Node3D

@onready var animation_player: AnimationPlayer = get_node("%AnimationPlayer")

var Current_Weapon = null

var Weapon_Stack = []

var Weapon_Indicator = 0

var Next_Wapon : String

var Weapon_List = {}

@export var _weapon_resources : Array[Weapon_Resource]

@export var Start_Weapons: Array[String] 

func _ready():
	Initialize(Start_Weapons)
	
func Initialize(_start_weapons:Array):
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_Name] = weapon

	for i in _start_weapons:
		Weapon_Stack.push_back(i)
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	enter()

func enter():
	animation_player.queue(Current_Weapon.Weapon_Name +" Activate_Anim")
	pass

func exit(_next_weapon : String):
	if _next_weapon != Current_Weapon.Weapon_Name:
		if animation_player.get_current_animation() != Current_Weapon.Deactivate_Anim:
			animation_player.play(Current_Weapon.Deactivate_Anim)
			Next_Wapon = _next_weapon

func Change_Weapon():
	pass

func changeGunUp():
	Weapon_Indicator = min(Weapon_Indicator+1,Weapon_Stack.size() - 1)
	exit(Weapon_Stack[Weapon_Indicator])

func changeGunDown():
	Weapon_Indicator = max(Weapon_Indicator-1,0)
	exit(Weapon_Stack[Weapon_Indicator])
