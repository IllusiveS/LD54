extends CharacterBody3D

@export var bullet_scene : PackedScene
@onready var bullet_spawn_point = %BulletSpawn

@onready var turret = $RootNode/Tank/Turret
@onready var cannon_pivot = $RootNode/Tank/Turret/CannonPivot

@onready var InputSync = $PlayerInput
@onready var Aim = $Aim

@export var RespawnPos : Vector3

const SPEED = 15.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	update_cam.call_deferred()

func update_cam():
	if player == multiplayer.get_unique_id():
		$RootNode/Tank/Turret/Camera3D.current = true
	else:
		Aim.visible = false

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $PlayerInput

func fire():
	var new_bullet : RigidBody3D = bullet_scene.instantiate()
	get_node("/root/Multiplayer/Level/GameLevel/Bullets").add_child(new_bullet, true)
	new_bullet.global_transform = bullet_spawn_point.global_transform
	new_bullet.apply_impulse(new_bullet.global_transform.basis.z * 400)

@onready var target_turret_rot = turret.global_basis
@onready var target_barrel_rot = cannon_pivot.basis

func _physics_process(delta):
	if bullet_spawn_point.is_colliding():
		Aim.global_position = lerp(Aim.global_position, bullet_spawn_point.get_collision_point(), 9.0 * delta)
		Aim.look_at(global_position)
	
	if global_position.y < -10.0:
		global_position = RespawnPos
	# Add the gravity.
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = InputSync.input_dir
	
	var direction = InputSync.direction
	var rot_speed = InputSync.rot_speed
	
	if direction:
		#rot_speed = -input_dir.x * SPEED * delta
		velocity = -direction * SPEED
	else:
		#rot_speed = move_toward(rot_speed, 0, SPEED)
		velocity.x = lerp(0.0, velocity.x, SPEED * delta)
		velocity.z = lerp(0.0, velocity.z, SPEED * delta)
	
	turret.global_basis = lerp(turret.global_basis.get_rotation_quaternion(), target_turret_rot.get_rotation_quaternion(), 5 * delta)
	
	cannon_pivot.basis = lerp(cannon_pivot.basis.get_rotation_quaternion(), target_barrel_rot.get_rotation_quaternion(), 5 * delta)
	
	var clamped_rot = clamp(cannon_pivot.rotation.z, deg_to_rad(-20), deg_to_rad(20))
	cannon_pivot.rotation.z = clamped_rot
	
	rotate_y(rot_speed * delta * SPEED)

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
