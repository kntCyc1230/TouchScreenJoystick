extends CharacterBody2D

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if dir:
		velocity = dir * 200
	else:
		velocity.x = move_toward(velocity.x, 0,200)
		velocity.y = move_toward(velocity.y, 0,200)
	
	move_and_slide()
	
