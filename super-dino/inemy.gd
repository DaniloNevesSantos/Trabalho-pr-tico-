extends CharacterBody2D


const SPEED = 700.0
const JUMP_VELOCITY = -400.0

@onready var RayCast = $RayCast as RayCast2D
@onready var textura = $textura
var direction = -1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if RayCast.is_colliding():
		direction *= -1
		RayCast.scale.x *= -1
	
	
	if direction == 1:
		textura.flip_h = true
	else:
		textura.flip_h = false
		
	velocity.x = direction * SPEED * delta
	

	move_and_slide()
