extends Area2D

var speed_bullet: float = 1000
var direction: Vector2

func _ready():
	direction = Vector2(1, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed_bullet * delta

	# Remove bullet
	var camera_x = get_viewport().get_camera_2d().global_position.x
	if position.x > (camera_x + get_viewport_rect().size.x) - 500:
		queue_free()
