extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var cellScale = .5
# Called when the node enters the scene tree for the first time.
func _ready():
    var vectorScale = Vector2(cellScale, cellScale)
    var vectorGridSize = Vector2(10,10)
    $HexGrid.create_grid(vectorScale, vectorGridSize)
    $Debugger.add_property($HexGrid, "selectionStack", "")
   # $Debugger.add_property($HexGrid, "availableNeighbors", "")
    $Debugger.add_property($HexGrid, "missingCells", "")
   # $Debugger.add_property($HexGrid, "eliminationQueue", "")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
