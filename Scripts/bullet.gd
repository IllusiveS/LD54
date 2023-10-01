extends RigidBody3D

@export var explosion_particle : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.s
func _process(delta):
	pass

func _on_body_entered(body):
	
	for overlapped_body in enemies:
		if overlapped_body is Enemy:
			overlapped_body.receive_damage(3.0)
		pass
	pass
	
	spawn_explosion.rpc()
	queue_free.call_deferred()
	if body is Enemy:
		body.receive_damage(10.0)
	

@rpc("authority", "call_local")
func spawn_explosion():
	var explosion = explosion_particle.instantiate()
	get_parent().add_child(explosion)
	explosion.emitting = true
	explosion.global_position = global_position

var enemies = []

func _on_area_3d_body_entered(body):
	if body is Enemy:
		enemies.append(body)
	pass # Replace with function body.


func _on_area_3d_body_exited(body):
	enemies.erase(body)
	pass # Replace with function body.
