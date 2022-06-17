extends Node
signal cell_pressed
signal cell_removed
signal cell_exploded
signal cell_type_signal

var level_editor = false
var cell_type = 0

func _ready():
    pass # Replace with function body.


func cell_pressed(coordinates: Vector2):
    emit_signal("cell_pressed", coordinates)
    
func cell_removed(coordinates: Vector2):
    emit_signal("cell_removed", coordinates)

func cell_exploded():
    emit_signal("cell_exploded")

func emit_cell_type(type):
    cell_type = type
    emit_signal("cell_type_signal",type)
