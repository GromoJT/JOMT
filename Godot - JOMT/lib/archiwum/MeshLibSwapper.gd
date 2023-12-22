@tool
extends Node3D

@export var MeshLib: MeshLibrary

@export var start: bool = false : set = set_start

var gridMaps:Array[GridMap] = []

func set_start(_val:bool)->void:
	gen()

func gen():
	for child in get_children():
		if child is GridMap:
			gridMaps.append(child)
	for x in gridMaps:
		if MeshLib != null:
			x.set_mesh_library(null)
			x.set_mesh_library(MeshLib)
		else:
			print("BRAK BIBLIOTEKI !!!")
