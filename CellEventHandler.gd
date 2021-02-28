extends Node
signal cell_pressed



func _ready():
    pass # Replace with function body.


func cell_pressed(coordinates: Vector2):
    emit_signal("cell_pressed", coordinates)
    
