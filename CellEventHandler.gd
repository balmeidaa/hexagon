extends Node
signal cell_pressed
signal cell_removed
signal cell_exploded

var level_editor = false


func _ready():
    pass # Replace with function body.


func cell_pressed(coordinates: Vector2):
    emit_signal("cell_pressed", coordinates)
    
func cell_removed(coordinates: Vector2):
    emit_signal("cell_removed", coordinates)

func cell_exploded():
    emit_signal("cell_exploded")
