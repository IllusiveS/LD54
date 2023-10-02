# player_input.gd
extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false


@export var input_dir : Vector2
@export var direction : Vector3
@export var rot_speed : float

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())
	
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

@rpc("any_peer", "call_local", "reliable")
func fire():
	get_parent().fire()

@rpc("any_peer", "call_local", "reliable")
func alt_fire():
	get_parent().alt_fire()
	
func _input(event):
	if event is InputEventMouseMotion:
		get_parent().target_turret_rot = get_parent().turret.global_basis.rotated(Vector3(0, 1, 0), -event.relative.x * get_process_delta_time())
		get_parent().target_barrel_rot = get_parent().cannon_pivot.basis.rotated(Vector3(0, 0, 1), event.relative.y * get_process_delta_time())

func _process(delta):
	if Input.is_action_just_pressed("fire"):
		fire.rpc()
	if Input.is_action_pressed("alt_fire"):
		alt_fire.rpc()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	direction = (get_parent().global_transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	rot_speed = -input_dir.x * get_parent().SPEED * delta
