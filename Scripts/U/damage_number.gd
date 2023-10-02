extends Label3D

@onready var dir = Vector3(randf_range(-3, 3), randf_range(10, 15), randf_range(-3, 3))

@export var damage := 1 :
	set(dam):
		damage = dam
		text = str(damage)

func _physics_process(delta):
	translate(dir * delta)
	dir = lerp(dir, Vector3(), delta * 3)


func _on_timer_timeout():
	queue_free()
