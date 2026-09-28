extends CharacterBody2D

const SPEED = 100.0

var pulo = -600

var virado = false
func _physics_process(delta: float) -> void:
	
	velocity += get_gravity()*delta
	
	
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_select"):
		velocity.y = pulo
		$Anim.play("jump")
	
	if Input.is_action_pressed('ui_left'):
		virado = true
		velocity.x = -1 * SPEED
		
	if Input.is_action_pressed('ui_right'):
		virado = false
		velocity.x = 1 * SPEED
	move_and_slide()
	
	if velocity == Vector2.ZERO:
		$"Anim".play("stop")
		$"Anim".flip_h  = virado
		
		
	else: 
		$"Anim".play("run")
		if velocity.x < 0:
			
			$"Anim".flip_h = true
		
		else: 
			$Anim.flip_h = false
