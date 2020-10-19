extends Spatial
var FS_SCENE = preload("res://FallingSlice.tscn")
var BREAD_MESH = preload("res://models/bread/bread_loaf.tres")
var TRAY_MESH = preload("res://models/tray/bakingTray.tres")
var CINNAMON_BREAD_MESH = preload("res://models/bread/cinnamon_bread.tres")
var MILK_BREAD_MESH = preload("res://models/bread/milk_bread_loaf.tres")
var BREAD_MAT1 = preload("res://models/bread/BlocksPaper_1.material")
var BREAD_MAT2 = preload("res://models/bread/BlocksPaper.material")
var IMPACT_FX = []
var CUBE_MESH = null

var current_mesh = null
var knife_ready = true
var rng = RandomNumberGenerator.new()
var speed = 0
var live_meshes = []
var last_mesh_instance = null
const OBJECTS_GAP = 2
export(Array, PoolColorArray) var ColorPalettes

#difficulty handling stuff.
var TOP_SPEED = 1
var ACCELERATION = 1
var TOP_SPEED_PER_COMBO = 	[2, 3, 4, 4, 5.5, 6]
var PIECES_PER_COMBO = 		[5, 4, 4, 3, 2, 2]
var NUM_LOAFS_COUNT = 		[1, 1, 2, 2, 1, 1]

var next_tray_spawn = 5
var last_sliced_mesh = null
var num_slices setget set_num_slices, get_num_slices
var total_slices = 0
var total_loafs_not_sliced = 0
var combo_count setget set_combo_count, get_combo_count
var score setget set_score, get_score
var items_cleared = 0
var loafs_eligible_for_combo = 0


func set_num_slices(val):
	num_slices = val
	$UI.update_num_slices(val)

func get_num_slices():
	return num_slices
	
func set_score(val):
	score = val

func get_score():
	return score

func set_combo_count(val):
	combo_count = val
	TOP_SPEED = TOP_SPEED_PER_COMBO[val]
	$UI.update_combo(val)
	if combo_count > 4:
		$ConfettiFx2.visible = true
		$CPUParticles.visible = true
		$ConfettiFx.visible = true
		$ConfettiFx3.visible = true
		pass
	elif combo_count > 3:
		$CPUParticles.visible = true
		$ConfettiFx3.visible = true
	else:
		$ConfettiFx.visible = false
		$ConfettiFx2.visible = false
		$CPUParticles.visible = false
		$ConfettiFx3.visible = false


func get_combo_count():
	return combo_count
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#	current_mesh = $MeshInstance
	rng.randomize()
	
	self.num_slices = 0
	self.score = 0
	self.combo_count = 0
	
	IMPACT_FX.push_back($ImpactFx)
	IMPACT_FX.push_back($ImpactFx1)
	IMPACT_FX.push_back($ImpactFx2)
	IMPACT_FX.push_back($ImpactFx3)
	IMPACT_FX.push_back($ImpactFx4)
	
	var CurrentPalette = ColorPalettes[rng.randi_range(0, ColorPalettes.size()-1)]
#	CurrentPalette = ColorPalettes[2]
	$Camera.environment.background_sky.ground_bottom_color = CurrentPalette[0]
	$ChoppingBoard.mesh.surface_get_material(0).albedo_color = CurrentPalette[1]
	BREAD_MAT1.albedo_color = CurrentPalette[2]
	BREAD_MAT2.albedo_color = CurrentPalette[3]
	
	$ConfettiFx.color_ramp.set_color(0, CurrentPalette[2])
	$ConfettiFx2.color_ramp.set_color(0, CurrentPalette[3])
#	$ConfettiFx.color_ramp.set_color(1, CurrentPalette[2])
	
	$UI.set_color_palette(CurrentPalette)
	
	CUBE_MESH = CubeMesh.new()
	CUBE_MESH.size.z = 6
	
	#add the first item on the roller.
	var mi = MeshInstance.new()
	mi.mesh = CINNAMON_BREAD_MESH
	last_mesh_instance = mi
	mi.transform.origin = Vector3(0, 0, -5)
	mi.material_override = BREAD_MAT1
	add_child(mi)
	live_meshes.push_back(mi)
	
	#add additional items
	for i in range(0, 4):
		mi = MeshInstance.new()
		live_meshes.push_back(mi)
		add_child(mi)
		update_mesh_item(mi)
		
	#stop the processing till the menu starts.
	set_physics_process(false)

func restart_game():
	rng.randomize()
	self.num_slices = 0
	self.score = 0
	self.combo_count = 0
	
	total_slices = 0
	total_loafs_not_sliced = 0
	TOP_SPEED = 2
	speed = 0
	current_mesh = null
	knife_ready = true
	items_cleared = 0
	loafs_eligible_for_combo = 0
	next_tray_spawn = 5
	last_sliced_mesh = null
	self.score = 0
	
	live_meshes[0].transform.origin = Vector3(0, 0, -5)
	live_meshes[0].mesh = CINNAMON_BREAD_MESH
	last_mesh_instance = live_meshes[0]
	live_meshes[0].material_override = BREAD_MAT1
	for i in range(1, 5):
		update_mesh_item(live_meshes[i])
	
	set_physics_process(true)

func set_colors():
	var CurrentPalette = ColorPalettes[rng.randi_range(0, ColorPalettes.size()-1)]
#	CurrentPalette = ColorPalettes[2]
	$Camera.environment.background_sky.ground_bottom_color = CurrentPalette[0]
	$ChoppingBoard.mesh.surface_get_material(0).albedo_color = CurrentPalette[1]
	BREAD_MAT1.albedo_color = CurrentPalette[2]
	BREAD_MAT2.albedo_color = CurrentPalette[3]
	
	$ConfettiFx.color_ramp.set_color(0, CurrentPalette[2])
	$ConfettiFx2.color_ramp.set_color(0, CurrentPalette[3])
	$UI.set_color_palette(CurrentPalette)
	
func on_game_over():
	set_physics_process(false)
	$UI/ColorRect/Score/Value.text = str(self.score)
	$Tween.interpolate_property($UI/ColorRect2, "color", Color(0, 0, 0, 0), Color.black, 0.25, 0, 0, 0.25)
	$Tween.interpolate_deferred_callback(self, 0.51, "set_colors")
	$Tween.interpolate_deferred_callback($UI, 0.6, "show_menu")
	$Tween.start()

	
func update_mesh_item(mesh_instance):
	next_tray_spawn -= 1
	#pick a random mesh for the mesh instance.
	var meshes_list = [TRAY_MESH, BREAD_MESH, CINNAMON_BREAD_MESH, MILK_BREAD_MESH]
	var mat_list = [BREAD_MAT1, BREAD_MAT2]
	
	var indx = rng.randi_range(1, meshes_list.size()-1)
	
	#force tray spanw if we have spawned enough objects before.
	if(next_tray_spawn <= 0):
		next_tray_spawn = rng.randi_range(5, 8)
		indx = 0
		
	mesh_instance.mesh = meshes_list[indx]
	
	#place the mesh instance beyond the last one with the specified gap.
	var last_mesh_aabb = last_mesh_instance.get_transformed_aabb()
	var offset = last_mesh_aabb.position.z #- last_mesh_aabb.size.z/2
	offset -= OBJECTS_GAP
	offset -= meshes_list[indx].get_aabb().size.z/2
	mesh_instance.transform.origin = Vector3(0, 0, offset)
	if indx == 0:
		mesh_instance.material_override = null
	else:
		indx = rng.randi_range(0, mat_list.size()-1)
		mesh_instance.material_override = mat_list[indx]
	
	#update the last_mesh_instance to the current one. 
	last_mesh_instance = mesh_instance
	

func update_verts(piece, drop_piece = false):
	var vertices = piece[0]
	for i in range(0, vertices.size()):
		var vertex = vertices[i]
		var mesh_z = current_mesh.transform.origin.z
		
		if drop_piece: 
			if vertex.z + mesh_z > 0:
				vertex.z += mesh_z
			else:
				vertex.z = 0
		else:
			if vertex.z + mesh_z > 0:
				vertex.z = -mesh_z
			else:
				vertex.z 
		
		vertices[i] = vertex
	piece[0] = vertices
	
func _physics_process(delta):
	if speed < TOP_SPEED:
		speed += delta * ACCELERATION
	elif speed > TOP_SPEED: #Decelerate faster.
		speed -= delta * ACCELERATION * 4
		
	current_mesh = null
	for mesh_instance in live_meshes:
		mesh_instance.transform.origin.z += delta * speed
		var mesh_aabb = mesh_instance.get_transformed_aabb()
		#HACK: for handling the low bb for the tray.
		if mesh_instance.mesh == TRAY_MESH:
			mesh_aabb.size.y = 100
			
		if mesh_aabb.size.z > 0.15 and $CuttingPlane.get_transformed_aabb().intersects(mesh_aabb):
			current_mesh = mesh_instance
		elif mesh_aabb.position.z > 4:
			items_cleared += 1
			update_mesh_item(mesh_instance)
			
	#figure out when the sliced object is changing. 
	if last_sliced_mesh == null: 
		last_sliced_mesh = current_mesh
	elif not(last_sliced_mesh == current_mesh) and not(current_mesh == null):
		#combo increments if you cut many pieces + combocount < 5
		if self.num_slices > PIECES_PER_COMBO[self.combo_count]:
			loafs_eligible_for_combo += 1
			if loafs_eligible_for_combo >= NUM_LOAFS_COUNT[self.combo_count]:
				loafs_eligible_for_combo = 0
				if self.combo_count < 5:
					self.combo_count += 1
				else:
					TOP_SPEED += 2
				
		elif self.num_slices == 0 and not(last_sliced_mesh.mesh == TRAY_MESH):
			total_loafs_not_sliced += 1
			self.combo_count = 0
			$UI.on_miss()
			if total_loafs_not_sliced == 3:
				on_game_over()
				
		total_slices += self.num_slices
		#add score based on the slices. 
		if self.combo_count > 4:
			self.score += 3 * self.num_slices
		elif self.combo_count > 2:
			self.score += 2 * self.num_slices
		else:
			self.score += self.num_slices
			
		self.num_slices = 0
		last_sliced_mesh = current_mesh
	
	if knife_ready and Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("slice")
			
		if current_mesh == null:
			var indx = rng.randi_range(1, 2)
			get_node("Chop" + str(indx)).play()
		elif current_mesh.mesh == TRAY_MESH:
			knife_ready = false
			self.combo_count = 0
			$AnimationPlayer.queue("shake")
			$PanHit.play()
			$ShakeTimer.start()
		else:
			var indx = rng.randi_range(1, 2)
			get_node("Chop" + str(indx)).play()
			handle_mesh_cutting()
			last_sliced_mesh = current_mesh
			self.num_slices += 1
			for impact_fx in IMPACT_FX:
				if impact_fx.emitting == false:
					impact_fx.one_shot = false
					impact_fx.restart()
					impact_fx.emitting = true
					impact_fx.one_shot = true
					impact_fx.color = current_mesh.material_override.albedo_color
					break

func handle_mesh_cutting():
	var mesh = current_mesh.mesh;
	var drop_part = mesh.surface_get_arrays(0)
	var keep_part = mesh.surface_get_arrays(0)

	update_verts(drop_part, true)
	update_verts(keep_part)

#		#part to retain.
	var keep_mesh = ArrayMesh.new()
	keep_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, keep_part)
	keep_mesh.surface_set_material(0, current_mesh.material_override)
	current_mesh.mesh = keep_mesh
	
	#part to drop.
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, drop_part)
	
	var fs_scene = FS_SCENE.instance()
	var mi = fs_scene.find_node("MeshInstance")
	mi.mesh = arr_mesh
	mi.mesh.surface_set_material(0, current_mesh.material_override)
#	mi.scale = current_mesh.scale
	add_child(fs_scene)


func _on_ShakeTimer_timeout():
	knife_ready = true;
	$AnimationPlayer.play("idle")
	pass # Replace with function body.
