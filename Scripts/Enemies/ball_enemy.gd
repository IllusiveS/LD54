extends CharacterBody3D
class_name Enemy

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var bullet_spawn : Node3D = $MeshInstance3D/BulletSpawn

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_dead = false
@export var health = 15.0
@onready var current_health = health
@export var pushback_mult = 1.0
var pushback_vec = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		set_process(true)
		set_physics_process(true)
	else:
		set_process(false)
		get_node("Controller").queue_free()
		nav_agent.queue_free()
		set_physics_process(false)

func go_to_point(point : Vector3):
	nav_agent.target_position = point

func slide():
	velocity += pushback_vec
	pushback_vec = lerp(pushback_vec, Vector3(), get_process_delta_time() * 9)
	move_and_slide()
	pass

func _physics_process(delta):
	if not is_on_floor() and not is_dead:
		velocity.y -= gravity * delta
		slide()
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
		slide()
	

func _on_navigation_agent_3d_velocity_computed(safe_velocity : Vector3):
	if not is_on_floor():
		return
	velocity = safe_velocity
	if safe_velocity.length() != 0.0:
		look_at(global_position + velocity, Vector3(0, 1, 0), true)
	slide()

func die():
	if is_dead == false:
		velocity = Vector3(0, 150, 0)
		is_dead = true
		nav_agent.queue_free()
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		queue_free()
		pass

@rpc("authority", "call_local")
func receive_damage(dmg : float, damage_source_pos : Vector3):
	current_health -= dmg
	var damage_num = preload("res://Scenes/UI/damage_number.tscn").instantiate()
	get_parent().add_child(damage_num)
	damage_num.damage = dmg
	damage_num.global_position = global_position
	pushback_vec += (global_position - damage_source_pos).normalized() * dmg * 2 * pushback_mult
	
	if current_health <= 0:
		die()
	pass


func _on_navigation_agent_3d_navigation_finished():
	nav_agent.queue_free()
	velocity = Vector3()
	pass # Replace with function body.

func attack_player(player):
	pass

