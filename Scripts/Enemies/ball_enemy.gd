extends CharacterBody3D
class_name Enemy

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_dead = false
var health = 10.0
var current_health = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		set_process(true)
		set_physics_process(true)
	else:
		set_process(false)
		nav_agent.queue_free()
		set_physics_process(false)

func go_to_point(point : Vector3):
	nav_agent.target_position = point

func _physics_process(delta):
	if not is_on_floor() and not is_dead:
		velocity.y -= gravity * delta
		move_and_slide()
		return
		
	if nav_agent != null && is_instance_valid(nav_agent):
		var target_pos = nav_agent.get_next_path_position()
		var dir = target_pos - global_position
		var dir_norm = dir.normalized()
		var speed = dir_norm * 195.0 * delta
		var grav = velocity.y
		velocity = speed
		velocity.y = grav
		nav_agent.velocity = speed
	else:
		#look_at(global_position + velocity, Vector3(0, 1, 0), true)
		move_and_slide()
	

func _on_navigation_agent_3d_velocity_computed(safe_velocity : Vector3):
	if not is_on_floor():
		return
	velocity = safe_velocity
	if safe_velocity.length() != 0.0:
		look_at(global_position + velocity, Vector3(0, 1, 0), true)
	move_and_slide()

func die():
	if is_dead == false:
		velocity = Vector3(0, 150, 0)
		is_dead = true
		nav_agent.queue_free()
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		queue_free()
		pass

func receive_damage(dmg : float):
	current_health -= dmg
	if current_health <= 0:
		die()
	pass


func _on_navigation_agent_3d_navigation_finished():
	nav_agent.queue_free()
	velocity = Vector3()
	pass # Replace with function body.
