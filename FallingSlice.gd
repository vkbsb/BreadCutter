extends RigidBody
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	linear_velocity.x  = rng.randf_range(-2, 5)
	linear_velocity.y = rng.randf_range(2, 5)
	linear_velocity.z = rng.randf_range(5, 10)
	
	angular_velocity.x = rng.randf_range(-5, 5)
	angular_velocity.y = rng.randf_range(-5, 5)
	angular_velocity.z = rng.randf_range(-5, 5)
	
	$CollisionShape.shape.height = $MeshInstance.get_aabb().size.z
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
