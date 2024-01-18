extends RayCast3D

class_name Surface

var current_coliding_surface : MeshInstance3D = null
var surface_sound_type : String
@onready var geo = Geometry3D
@onready var body = get_parent()

var mdt_array = []

func _physics_process(_delta: float) -> void:
	#pass
	#print(get_surface_sound_type())
	if is_colliding():
		var col = get_collider()
		#print(col.get_parent())
		if col.get_child_count() != 0:
			if current_coliding_surface != col.get_child(0) and col.get_child(0) is MeshInstance3D:
				current_coliding_surface = col.get_child(0)
				if current_coliding_surface.mesh.get_surface_count() == 1:
					analyse_mat_path(current_coliding_surface.get_active_material(0))
					mdt_array.clear()
					return
				else:
					build_mesh_mdts()
		extract_surface_sound_type(get_collision_point())
		
func build_mesh_mdts():
	mdt_array.clear()
	var mesh = current_coliding_surface.mesh
	for s in mesh.get_surface_count():
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(mesh,s)
		mdt_array.append(mdt)

var last_mdt : MeshDataTool = null

func extract_surface_sound_type(point):
	for mdt in mdt_array:
		if last_mdt == mdt:
			continue
		for v in range(mdt.get_vertex_count()):
			var faces = mdt.get_vertex_faces(v)
			for f in faces:
				if mdt.get_face_normal(f).dot(Vector3.UP) < 0.1:
					continue
				var tri = [mdt.get_vertex(mdt.get_face_vertex(f,0)),mdt.get_vertex(mdt.get_face_vertex(f,1)),mdt.get_vertex(mdt.get_face_vertex(f,2))]
				#print("*-*-*")
				#print(tri)
				if geo.ray_intersects_triangle(global_transform.origin,global_transform.origin.direction_to(point),current_coliding_surface.to_global(tri[0]),current_coliding_surface.to_global(tri[1]),current_coliding_surface.to_global((tri[2]))):
					last_mdt = mdt
					analyse_mat_path(mdt.get_material())
					return

func analyse_mat_path(material):
	var mat_path : String = str(material.resource_path)
	if "grass" in mat_path:
		surface_sound_type = "GRASS"
	elif "rock" in mat_path or "stone" in mat_path:
		surface_sound_type = "STONE"
	elif "metal" in mat_path:
		surface_sound_type = "METAL"
	elif "tile" in mat_path:
		surface_sound_type = "TILE"
	elif "fabric" in mat_path:
		surface_sound_type = "FABRIC"	
	else:
		surface_sound_type = "NULL"
	body.set_footsteps_profile(surface_sound_type)
	
	print(mat_path)
func get_surface_sound_type():
	return surface_sound_type
