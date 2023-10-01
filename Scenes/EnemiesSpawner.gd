extends Node3D

@export var EnemyToSpawn : PackedScene


@rpc("authority", "call_local")
func spawn_wave():
	for i in range(0, 10):
		var timer = get_tree().create_timer(0.1 * i)
		timer.timeout.connect(self.spawn)
		pass
	pass

func spawn():
	var enemy = EnemyToSpawn.instantiate()
	get_node("../Enemies").add_child(enemy)
	
	enemy.global_position = get_children().pick_random().global_position
	enemy.global_position += Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))


func _on_timer_timeout():
	spawn_wave.rpc()
	pass # Replace with function body.
