extends RigidBody3D

@export var damage = 1.0

func _on_body_entered(body):
	if body.has_method("receive_damage"):
		body.receive_damage.rpc(damage, global_position)
		pass
	queue_free()
