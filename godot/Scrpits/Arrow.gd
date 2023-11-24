extends Area2D

var speed = 750
@export var direction : int = 1

func _physics_process(delta):

	if direction == 1:
		position += transform.x * speed * delta
		get_node( "Arrow" ).set_flip_h( false )
	if direction == -1:
		position -= transform.x * speed * delta
		get_node( "Arrow" ).set_flip_h( true )


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.queue_free()
		#area.explode()
		queue_free()
