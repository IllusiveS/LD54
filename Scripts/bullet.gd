extends RigidBody3D

@export var explosion_particle : PackedScene

func _on_body_entered(body):
	var direct_hit = null
	if body.has_method("receive_damage"):
		body.receive_damage.rpc(15.0, global_position)
		direct_hit = body
	
	for overlapped_body in enemies:
		if overlapped_body != direct_hit and overlapped_body.has_method("receive_damage"):
			overlapped_body.receive_damage.rpc(5.0, global_position)
		pass
	pass
	
	spawn_explosion.rpc()
	queue_free.call_deferred()

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
