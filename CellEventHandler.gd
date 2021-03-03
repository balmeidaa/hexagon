extends Node
signal cell_pressed
signal cell_removed




func _ready():
    pass # Replace with function body.


func cell_pressed(coordinates: Vector2):
    emit_signal("cell_pressed", coordinates)
    
func cell_removed(coordinates: Vector2):
    emit_signal("cell_removed", coordinates)
